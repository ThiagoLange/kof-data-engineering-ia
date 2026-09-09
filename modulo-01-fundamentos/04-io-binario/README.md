# Lab 1.4 — I/O Binário e Compressão de Dados

## Objetivo

Construir um formato binário customizado ("KOF1") com header mágico e
records length-prefixed, persisti-lo com I/O binário real
(`File.writeBytes()`/`readBytes()`), e implementar compressão RLE
(Run-Length Encoding) manual sobre os bytes medindo a taxa de compressão.

## Conceito

Formatos binários próprios são a base de Parquet, Arrow, protocol buffers e
de todo checkpoint de modelo: em vez de texto, os dados viajam como bytes
densos com um layout documentado. Os blocos fundamentais são sempre os
mesmos:

1. **Magic header** — os bytes `'K','O','F','1'` identificam o formato e sua
   versão, permitindo rejeitar arquivos estranhos logo na abertura.
2. **Campos de tamanho fixo** — `id` como inteiro de 4 bytes big-endian e
   `salary` como IEEE-754 binary64 de 8 bytes, bit-empacotado à mão
   (decomposição estilo frexp: sinal, expoente, mantissa) porque a stdlib de
   Kof 0.1.3-beta não expõe bit-cast de `Double`.
3. **Campos length-prefixed** — `name` como UTF-8 precedido por um `u16` com
   o número de bytes, eliminando delimitadores e ambiguidade.
4. **Compressão** — RLE como pares `(count, value)` com contagem limitada a
   255, o mesmo estágio de "run" dos codecs reais (gzip/DEFLATE), sem a
   etapa de entropia.

Em Kof, `kof.io` provê `File.readBytes()`/`writeBytes()` sobre arrays `Int[]`
(valores 0-255), e o buffer de escrita é um `List<Int>` com cursores
explícitos — um ByteBuffer portátil e honesto.

## Diagrama

```
 datasets/employees.csv
         |
         v
   readCsv() -> List<EmpBin>
         |
         v
   encodeFrame()                decodeFrame()
   +------------------+         +------------------+
   | 'K' 'O' 'F' '1'  |   .bin  | check magic      |
   | u16 count        | ======> | loop records:    |
   | per record:      | writeBytes/readBytes | u32 id (BE)      |
   |   u32 id (BE)    |         |   f64 salary     |
   |   f64 salary     |         |   u16 len + UTF-8|
   |   u16 len + UTF-8|         +------------------+
   +------------------+                |
         |                             v
         v                       field-by-field verify
   rleEncode() (count,value)     vs source rows
         |
         v
   ratio = packed*100/raw  (medida em %)
```

## Dataset

`datasets/employees.csv` — 6 linhas com ausências propositais: `salary`
vazio (Eve) vira o sentinel `0.0` (mesma convenção do Lab 1.1) e `name`
vazio (linha 6) viaja como length-prefix `0`. Ideal para validar que o
formato binário não confunde "ausente" com lixo de padding.

## Comandos

```bash
# da raiz do repo
kof run modulo-01-fundamentos/04-io-binario/lab.kof
kof test modulo-01-fundamentos/04-io-binario/exercise.kof
```

O lab grava `employees.kof1.bin` no próprio diretório do lab durante o
demo e o apaga ao final (cleanup verificado na saída).

## Padrões & Idiomática Kof

- **Decode puro com cursor explícito** — funções de leitura recebem `pos` e
  retornam `(value, next)` via records (`IntRes`/`DblRes`/`StrRes`); nada de
  estado global ou retorno nulo silencioso.
- **`throw`/`catch (String e)`** para qualquer violação de formato (magic
  inválido, truncamento, bytes sobrando, campo fora de faixa).
- **IEEE-754 por aritmética exata** — divisão/multiplicação por potências de
  2 e `m - 1.0` não perdem precisão em nenhuma etapa, então o roundtrip é
  bit-exato (verificado contra `struct.pack(">d")` do CPython no
  `exercise.kof`).
- **RLE com cap de 255** — runs longos viram vários pares; dados de alta
  entropia (doubles!) expandem, e isso é mostrado de propósito: codec real
  só aplica RLE acima de um run mínimo e adiciona codificação de entropia.
- **Aritmética Double segura (COMP002)** — RHS puramente Double; variáveis
  `Int` entram só como termo aditivo (`acc * 256.0 + bj`), nunca como
  multiplicando (`bj * 1.0` quebra o frame do ASM).

## Gaps & Limitações

- **Sem bit-cast de `Double`** — não existe `Double.toBits()`; o codec IEEE-754
  é feito por decomposição aritmética. `NaN`, `Infinity` e subnormais são
  rejeitados com `throw` (o dataset não os contém; formatos reais também
  tratam esses casos explicitamente).
- **Sem conversão Int/Char → String** — `"A" + 'B'` concatena o *código
  decimal* (66), não o caractere. O decode de strings usa uma lookup table
  de ASCII imprimível (32..126) com `substring`; codepoints não-ASCII no
  wire **lançam exceção** (o formato é UTF-8 de verdade na escrita — 1 a 3
  bytes — mas o runtime não reconstrói o caractere). Novo gap a consolidar
  em `docs/LIMITACOES-KOF-0.1.3.md`.
- **`arr == null` em `Int[]` gera `VerifyError`** no runtime (JVM) — nunca
  compare o array de `readBytes()` com `null`; use `File(path).exists()`
  antes de ler. Novo bug a consolidar em `docs/LIMITACOES-KOF-0.1.3.md`.
- **`intVar * 1.0` dentro de `while` dispara COMP002** (frame crash do ASM);
  use a variável Int como termo aditivo (`acc * 256.0 + bj`), que a
  linguagem alarga implicitamente. Novo bug a consolidar.
- **`charAt` retorna code unit UTF-16** (JVM) — surrogate pairs não são
  combinados; o codec trata cada codepoint < 0x10000 (BMP).
- **`-0.0` decode como `+0.0`** (bit de sinal do zero não é preservado na
  leitura); salários não-negativos do dataset não são afetados.
- **u32 limitado à faixa de `Int`** (0..2^31-1) por ausência de unsigned;
  ids de employee estão muito abaixo do limite.
- RLE demonstrado em memória; o `.bin` persistido é o frame KOF1 raw (a
  camada de compressão é composicional — basta empacotar `rleEncode(frame)`
  no mesmo transporte).
