## 0.2.11

- Changes in example file `example/example.dart`.
- Changes in example file `example/example_ex.dart`.
- Changes in the file `README.md`.
- The parsers has been rebuilt using the new version of the `peg` parser generation tool.

## 0.2.10

- Changes to example file `example/example_ex.dart`.
- The parsers has been rebuilt using the new version of the `peg` parser generation tool.

## 0.2.9

- Changes to grammar file `csv_parser.peg`.
- Changes to grammar file `csv_ex_parser.peg`.
- The parsers has been rebuilt using the new version of the `peg` parser generation tool.

## 0.2.8

- The parsers has been rebuilt using the new version of the `peg` parser generation tool.

## 0.2.7

- The parsers has been rebuilt using the new version of the `peg` parser generation tool.

## 0.2.6

- The parsers has been rebuilt using the new version of the `peg` parser generation tool. Converters are now generated automatically and, in addition, the performance of parsers has increased.

## 0.2.5

- Breaking change. The converters have been renamed and separated into different files. This is done because in future versions they will be generated automatically by the parser tool.

## 0.2.4

- Changes to example file `example/example.dart`.
- Changes to file `README.md`.
- Implemented converters `FastCsvConverter`, `FastCsvExConverter`.
- Changes to grammar file `csv_ex_parser.peg`.

## 0.2.3

- Changes to example file `example/example.dart`.
- Changes to file `README.md`.

## 0.2.2

- Changes to example file `example/example.dart`.

## 0.2.1

- Added experimental support for event-based streaming parsing.
- Added an example of streaming parsing of 1 000 000 rows.

## 0.2.0

- The parsers have been recreated using PEG grammars.

## 0.1.44

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.43

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.42

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.41

- The parsers has been rebuilt using the new version of `parser_builder`
- The generated parsers no longer have dependencies and the size of the code is entirely determined by the size of the parser, which allows them to be used in lightweight web applications
- Implemented the ability to generate an error `Unterminated string` indicating the position at the beginning of the string value in the field in which this error was detected. This makes it much easier to find format violations. This was implemented using the new features in `parser_builder`

## 0.1.40

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.39

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.38

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.37

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.36

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.35

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.34

- Changed dependency in `pubspec.yaml` for `parser_builder` from `github` to `pub.dev`.

## 0.1.33

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.32

- Minor changes in the `README.md` file

## 0.1.31

- The parser has become a little smaller after rebuilding with new version of `parser_builder`

## 0.1.30

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.29

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.28

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.27

- The parsers has been rebuilt using the new version of `parser_builder` following improvements to parser error reporting procedures in `parser_builder`

## 0.1.26

- The parser has become a little faster after rebuilding with new version of `parser_builder`

## 0.1.25

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.24

- The parser has become a little faster after rebuilding with new version of `parser_builder`

## 0.1.23

- The parser definition (grammar ) has been slightly modified to match the changes introduced in `parser_builder`

## 0.1.22

- The parser has become a little faster after rebuilding with new version of `parser_builder`
- Configurable parser has become faster after adding new features to `parser_builder` to create efficient configurable parsers. Now the `fast_csv_ex` parser has become about 15% faster. Now it about 15% slower than the non-configurable parser (before that the difference was 30%). Not much, but it's always beneficial

## 0.1.21

- The parser has become a little faster after rebuilding with new version of `parser_builder`

## 0.1.20

- The parser has become a little faster after rebuilding with new version of `parser_builder`

## 0.1.19

- The parsers has been rebuilt using the new version of `parser_builder` after fixing a bug in `parser builder`

## 0.1.17

- The parser has become a much faster after rebuilding with new version of `parser_builder`

## 0.1.16

- The parser has become a little faster after rebuilding with new version of `parser_builder`

## 0.1.15

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.14

- The parser has become a little faster after rebuilding with new version of `parser_builder`

## 0.1.12

- The parsers has been rebuilt using the new version of `parser_builder`
- Minor changes in parser grammar

## 0.1.11

- The parsers has been rebuilt using the new version of `parser_builder`
- Minor changes in parser grammar

## 0.1.10

- The parsers has been rebuilt using the new version of `parser_builder`

## 0.1.9

- Slightly reduced parser size by rebuilding with new version of `parser_builder`

## 0.1.8

- Non-configurable parser has become a little faster after rebuilding with new version of `parser_builder`
- The updated version of the parsers is able to parse more data that does not fully conform with the specification (except for data with a structural format violation)

## 0.1.7

- Added parser `fast_csv_ex.dart`, which allows to configure the field separator

## 0.1.6

- The parser has become a little faster after rebuilding with new version of `parser_builder`

## 0.1.5

- Slightly reduced parser size by rebuilding with new version of `parser_builder`

## 0.1.4

- Slightly reduced parser size by rebuilding with new version of `parser_builder`

## 0.1.3

- Slightly reduced parser size by rebuilding with new version of `parser_builder`

## 0.1.2

- Minor changes in grammar (to make it easier to understand)

## 0.1.1

- Small changes in file `README.md`

## 0.1.0

- Initial release