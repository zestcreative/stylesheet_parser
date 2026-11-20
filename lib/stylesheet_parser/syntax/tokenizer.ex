# Generated from lib/stylesheet_parser/syntax/tokenizer.ex.exs, do not edit.
# Generated at 2026-11-20 21:44:54Z.

defmodule StylesheetParser.Syntax.Tokenizer do
  @moduledoc ~S"""
  The [tokenizer](https://www.w3.org/TR/css-syntax-3/#tokenization) of CSS Syntax Level 3, over
  preprocessed input (`StylesheetParser.tokenize/1` turns `\r\n`, `\r` and `\f` into `\n` and NUL into
  U+FFFD).

  Each token is `{type, value, [line: line, column: column]}`, where it starts, columns counting
  bytes from 1. Its value is its source text: a string keeps its quotes, and escapes stay escaped
  (`StylesheetParser.unescape/1` decodes them). Comments are dropped, an unclosed one running to
  the end.

  | Type | Value | Such as |
  | --- | --- | --- |
  | `:ident` | the name | `color`, `--gap`, `\31 0` |
  | `:function` | the name and its `(`; a `StylesheetParser.Function` among component values | `var(` |
  | `:at_keyword` | the name and its `@` | `@media` |
  | `:hash` | the name and its `#` | `#main`, `#f00` |
  | `:string` | the string, with its quotes | `"a.png"` |
  | `:bad_string` | a string with a newline in it, up to the newline | `"a` |
  | `:url` | the whole `url()` without quotes, or with escapes in `url` | `url(a.png)`, `u\72l(a.png)` |
  | `:bad_url` | a `url()` with whitespace, a quote or a `(` inside | `url(a b)` |
  | `:number` | the number | `12`, `-0.5`, `1e3` |
  | `:percentage` | the number, without its `%` | `50` for `50%` |
  | `:dimension` | `[number, unit]` | `["1", "px"]` |
  | `:whitespace` | the whitespace | `" "`, `"\n  "` |
  | `:delim` | any other code point | `>`, `.`, `!` |
  | `:colon`, `:semicolon`, `:comma` | `:`, `;`, `,` | |
  | `:lparen`, `:rparen`, `:lbracket`, `:rbracket`, `:lcurly`, `:rcurly` | the bracket; a `StylesheetParser.SimpleBlock` among component values | `(` |
  | `:cdo`, `:cdc` | `<!--`, `-->` | |
  | `:urange` | a unicode range, only in a `unicode-range` declaration's value | `U+0-7F` |

      iex> StylesheetParser.tokenize("a { margin: 1px }")
      {:ok,
       [
         {:ident, "a", [line: 1, column: 1]},
         {:whitespace, " ", [line: 1, column: 2]},
         {:lcurly, "{", [line: 1, column: 3]},
         {:whitespace, " ", [line: 1, column: 4]},
         {:ident, "margin", [line: 1, column: 5]},
         {:colon, ":", [line: 1, column: 11]},
         {:whitespace, " ", [line: 1, column: 12]},
         {:dimension, ["1", "px"], [line: 1, column: 13]},
         {:whitespace, " ", [line: 1, column: 16]},
         {:rcurly, "}", [line: 1, column: 17]}
       ]}
  """

  # The template for `tokenizer.ex`, so NimbleParsec isn't needed at runtime. After changing it:
  #
  #     mix nimble_parsec.compile lib/stylesheet_parser/syntax/tokenizer.ex.exs

  @doc false
  # Each token as `{type, value, metadata}`, like Elixir AST: `[line: l, column: c]` where it
  # starts, columns counting bytes from 1.
  def at([{[{[], {line, line_offset}}], offset}, {type, value}]),
    do: {type, value, [line: line, column: offset - line_offset + 1]}

  @doc """
  Parses the given `binary` as consume.

  Returns `{:ok, [token], rest, context, position, byte_offset}` or
  `{:error, reason, rest, context, line, byte_offset}` where `position`
  describes the location of the consume (start position) as `{line, offset_to_start_of_line}`.

  To column where the error occurred can be inferred from `byte_offset - offset_to_start_of_line`.

  ## Options

    * `:byte_offset` - the byte offset for the whole binary, defaults to 0
    * `:line` - the line and the byte offset into that line, defaults to `{1, byte_offset}`
    * `:context` - the initial context value. It will be converted to a map

  """
  @spec consume(binary, keyword) ::
          {:ok, [term], rest, context, line, byte_offset}
          | {:error, reason, rest, context, line, byte_offset}
        when line: {pos_integer, byte_offset},
             byte_offset: non_neg_integer,
             rest: binary,
             reason: String.t(),
             context: map
  def consume(binary, opts \\ []) when is_binary(binary) do
    context = Map.new(Keyword.get(opts, :context, []))
    byte_offset = Keyword.get(opts, :byte_offset, 0)

    line =
      case Keyword.get(opts, :line, 1) do
        {_, _} = line -> line
        line -> {line, byte_offset}
      end

    case consume__0(binary, [], [], context, line, byte_offset) do
      {:ok, acc, rest, context, line, offset} ->
        {:ok, :lists.reverse(acc), rest, context, line, offset}

      {:error, _, _, _, _, _} = error ->
        error
    end
  end

  defp consume__0(rest, acc, stack, context, line, offset) do
    consume__2(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__2(rest, acc, stack, context, line, offset) do
    consume__973(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__4(rest, acc, stack, context, line, offset) do
    consume__5(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__5(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__6(
      rest,
      [{[{[], comb__line}], comb__offset}] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset
    )
  end

  defp consume__5(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    consume__1(rest, acc, stack, context, line, offset)
  end

  defp consume__6(rest, acc, stack, context, line, offset) do
    consume__961(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__8(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__9(
      rest,
      [delim: <<x0::utf8>>] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__8(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    consume__1(rest, acc, stack, context, line, offset)
  end

  defp consume__9(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__10(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__8(rest, [], stack, context, line, offset)
  end

  defp consume__11(<<";", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__12(rest, [semicolon: ";"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__11(rest, acc, stack, context, line, offset) do
    consume__10(rest, acc, stack, context, line, offset)
  end

  defp consume__12(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__13(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__11(rest, [], stack, context, line, offset)
  end

  defp consume__14(<<":", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__15(rest, [colon: ":"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__14(rest, acc, stack, context, line, offset) do
    consume__13(rest, acc, stack, context, line, offset)
  end

  defp consume__15(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__16(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__14(rest, [], stack, context, line, offset)
  end

  defp consume__17(<<",", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__18(rest, [comma: ","] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__17(rest, acc, stack, context, line, offset) do
    consume__16(rest, acc, stack, context, line, offset)
  end

  defp consume__18(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__19(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__17(rest, [], stack, context, line, offset)
  end

  defp consume__20(<<"}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__21(rest, [rcurly: "}"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__20(rest, acc, stack, context, line, offset) do
    consume__19(rest, acc, stack, context, line, offset)
  end

  defp consume__21(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__22(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__20(rest, [], stack, context, line, offset)
  end

  defp consume__23(<<"{", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__24(rest, [lcurly: "{"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__23(rest, acc, stack, context, line, offset) do
    consume__22(rest, acc, stack, context, line, offset)
  end

  defp consume__24(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__25(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__23(rest, [], stack, context, line, offset)
  end

  defp consume__26(<<"]", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__27(rest, [rbracket: "]"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__26(rest, acc, stack, context, line, offset) do
    consume__25(rest, acc, stack, context, line, offset)
  end

  defp consume__27(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__28(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__26(rest, [], stack, context, line, offset)
  end

  defp consume__29(<<"[", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__30(rest, [lbracket: "["] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__29(rest, acc, stack, context, line, offset) do
    consume__28(rest, acc, stack, context, line, offset)
  end

  defp consume__30(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__31(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__29(rest, [], stack, context, line, offset)
  end

  defp consume__32(<<")", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__33(rest, [rparen: ")"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__32(rest, acc, stack, context, line, offset) do
    consume__31(rest, acc, stack, context, line, offset)
  end

  defp consume__33(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__34(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__32(rest, [], stack, context, line, offset)
  end

  defp consume__35(<<"(", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__36(rest, [lparen: "("] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__35(rest, acc, stack, context, line, offset) do
    consume__34(rest, acc, stack, context, line, offset)
  end

  defp consume__36(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__37(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__35(rest, [], stack, context, line, offset)
  end

  defp consume__38(rest, acc, stack, context, line, offset) do
    consume__39(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__39(rest, acc, stack, context, line, offset) do
    consume__40(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__40(<<"@", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__41(rest, ["@"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__40(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__37(rest, acc, stack, context, line, offset)
  end

  defp consume__41(rest, acc, stack, context, line, offset) do
    consume__42(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__42(rest, acc, stack, context, line, offset) do
    consume__68(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__44(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__45(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__44(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    consume__37(rest, acc, stack, context, line, offset)
  end

  defp consume__45(rest, acc, stack, context, line, offset) do
    consume__53(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__47(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__48("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__47(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, _, _, acc | stack] = stack
    consume__37(rest, acc, stack, context, line, offset)
  end

  defp consume__48(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__46(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__49(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__47(rest, [], stack, context, line, offset)
  end

  defp consume__50(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__51(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__50(rest, acc, stack, context, line, offset) do
    consume__49(rest, acc, stack, context, line, offset)
  end

  defp consume__51(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__46(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__52(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__50(rest, [], stack, context, line, offset)
  end

  defp consume__53(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__54(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__53(rest, acc, stack, context, line, offset) do
    consume__52(rest, acc, stack, context, line, offset)
  end

  defp consume__54(rest, acc, stack, context, line, offset) do
    consume__56(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__56(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__57(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__56(rest, acc, stack, context, line, offset) do
    consume__55(rest, acc, stack, context, line, offset)
  end

  defp consume__55(rest, acc, [_ | stack], context, line, offset) do
    consume__58(rest, acc, stack, context, line, offset)
  end

  defp consume__57(rest, acc, [1 | stack], context, line, offset) do
    consume__58(rest, acc, stack, context, line, offset)
  end

  defp consume__57(rest, acc, [count | stack], context, line, offset) do
    consume__56(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__58(rest, acc, stack, context, line, offset) do
    consume__62(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__60(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__59(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__61(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__60(rest, [], stack, context, line, offset)
  end

  defp consume__62(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__63(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__62(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__63(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__62(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__63(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__62(rest, acc, stack, context, line, offset) do
    consume__61(rest, acc, stack, context, line, offset)
  end

  defp consume__63(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__59(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__59(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__46(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__46(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__43(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__64(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__44(rest, [], stack, context, line, offset)
  end

  defp consume__65(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or x0 === 95 do
    consume__66(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__65(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__66(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__65(rest, acc, stack, context, line, offset) do
    consume__64(rest, acc, stack, context, line, offset)
  end

  defp consume__66(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__43(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__67(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__65(rest, [], stack, context, line, offset)
  end

  defp consume__68(<<"-", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__69(rest, ["-"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__68(rest, acc, stack, context, line, offset) do
    consume__67(rest, acc, stack, context, line, offset)
  end

  defp consume__69(rest, acc, stack, context, line, offset) do
    consume__95(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__71(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__72(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__71(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__67(rest, acc, stack, context, line, offset)
  end

  defp consume__72(rest, acc, stack, context, line, offset) do
    consume__80(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__74(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__75("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__74(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__67(rest, acc, stack, context, line, offset)
  end

  defp consume__75(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__73(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__76(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__74(rest, [], stack, context, line, offset)
  end

  defp consume__77(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__78(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__77(rest, acc, stack, context, line, offset) do
    consume__76(rest, acc, stack, context, line, offset)
  end

  defp consume__78(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__73(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__79(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__77(rest, [], stack, context, line, offset)
  end

  defp consume__80(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__81(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__80(rest, acc, stack, context, line, offset) do
    consume__79(rest, acc, stack, context, line, offset)
  end

  defp consume__81(rest, acc, stack, context, line, offset) do
    consume__83(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__83(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__84(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__83(rest, acc, stack, context, line, offset) do
    consume__82(rest, acc, stack, context, line, offset)
  end

  defp consume__82(rest, acc, [_ | stack], context, line, offset) do
    consume__85(rest, acc, stack, context, line, offset)
  end

  defp consume__84(rest, acc, [1 | stack], context, line, offset) do
    consume__85(rest, acc, stack, context, line, offset)
  end

  defp consume__84(rest, acc, [count | stack], context, line, offset) do
    consume__83(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__85(rest, acc, stack, context, line, offset) do
    consume__89(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__87(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__86(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__88(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__87(rest, [], stack, context, line, offset)
  end

  defp consume__89(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__90(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__89(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__90(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__89(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__90(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__89(rest, acc, stack, context, line, offset) do
    consume__88(rest, acc, stack, context, line, offset)
  end

  defp consume__90(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__86(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__86(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__73(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__73(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__70(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__91(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__71(rest, [], stack, context, line, offset)
  end

  defp consume__92(<<"-", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__93(rest, ["-"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__92(rest, acc, stack, context, line, offset) do
    consume__91(rest, acc, stack, context, line, offset)
  end

  defp consume__93(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__70(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__94(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__92(rest, [], stack, context, line, offset)
  end

  defp consume__95(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or x0 === 95 do
    consume__96(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__95(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__96(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__95(rest, acc, stack, context, line, offset) do
    consume__94(rest, acc, stack, context, line, offset)
  end

  defp consume__96(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__70(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__70(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__43(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__43(rest, acc, stack, context, line, offset) do
    consume__98(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__98(rest, acc, stack, context, line, offset) do
    consume__121(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__100(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__101(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__100(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__97(rest, acc, stack, context, line, offset)
  end

  defp consume__101(rest, acc, stack, context, line, offset) do
    consume__109(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__103(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__104("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__103(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__97(rest, acc, stack, context, line, offset)
  end

  defp consume__104(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__102(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__105(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__103(rest, [], stack, context, line, offset)
  end

  defp consume__106(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__107(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__106(rest, acc, stack, context, line, offset) do
    consume__105(rest, acc, stack, context, line, offset)
  end

  defp consume__107(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__102(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__108(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__106(rest, [], stack, context, line, offset)
  end

  defp consume__109(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__110(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__109(rest, acc, stack, context, line, offset) do
    consume__108(rest, acc, stack, context, line, offset)
  end

  defp consume__110(rest, acc, stack, context, line, offset) do
    consume__112(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__112(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__113(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__112(rest, acc, stack, context, line, offset) do
    consume__111(rest, acc, stack, context, line, offset)
  end

  defp consume__111(rest, acc, [_ | stack], context, line, offset) do
    consume__114(rest, acc, stack, context, line, offset)
  end

  defp consume__113(rest, acc, [1 | stack], context, line, offset) do
    consume__114(rest, acc, stack, context, line, offset)
  end

  defp consume__113(rest, acc, [count | stack], context, line, offset) do
    consume__112(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__114(rest, acc, stack, context, line, offset) do
    consume__118(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__116(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__115(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__117(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__116(rest, [], stack, context, line, offset)
  end

  defp consume__118(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__119(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__118(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__119(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__118(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__119(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__118(rest, acc, stack, context, line, offset) do
    consume__117(rest, acc, stack, context, line, offset)
  end

  defp consume__119(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__115(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__115(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__102(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__102(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__99(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__120(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__100(rest, [], stack, context, line, offset)
  end

  defp consume__121(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    consume__122(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__121(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__122(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__121(rest, acc, stack, context, line, offset) do
    consume__120(rest, acc, stack, context, line, offset)
  end

  defp consume__122(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__99(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__97(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__123(rest, acc, stack, context, line, offset)
  end

  defp consume__99(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__98(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__123(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__124(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__124(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__125(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__125(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__126(
      rest,
      [
        at_keyword:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__126(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__127(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__38(rest, [], stack, context, line, offset)
  end

  defp consume__128(<<"<!--", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__129(rest, [cdo: "<!--"] ++ acc, stack, context, comb__line, comb__offset + 4)
  end

  defp consume__128(rest, acc, stack, context, line, offset) do
    consume__127(rest, acc, stack, context, line, offset)
  end

  defp consume__129(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__130(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__128(rest, [], stack, context, line, offset)
  end

  defp consume__131(rest, acc, stack, context, line, offset) do
    consume__132(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__132(rest, acc, stack, context, line, offset) do
    consume__133(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__133(rest, acc, stack, context, line, offset) do
    consume__159(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__135(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__136(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__135(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__130(rest, acc, stack, context, line, offset)
  end

  defp consume__136(rest, acc, stack, context, line, offset) do
    consume__144(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__138(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__139("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__138(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, _, acc | stack] = stack
    consume__130(rest, acc, stack, context, line, offset)
  end

  defp consume__139(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__137(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__140(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__138(rest, [], stack, context, line, offset)
  end

  defp consume__141(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__142(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__141(rest, acc, stack, context, line, offset) do
    consume__140(rest, acc, stack, context, line, offset)
  end

  defp consume__142(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__137(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__143(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__141(rest, [], stack, context, line, offset)
  end

  defp consume__144(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__145(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__144(rest, acc, stack, context, line, offset) do
    consume__143(rest, acc, stack, context, line, offset)
  end

  defp consume__145(rest, acc, stack, context, line, offset) do
    consume__147(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__147(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__148(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__147(rest, acc, stack, context, line, offset) do
    consume__146(rest, acc, stack, context, line, offset)
  end

  defp consume__146(rest, acc, [_ | stack], context, line, offset) do
    consume__149(rest, acc, stack, context, line, offset)
  end

  defp consume__148(rest, acc, [1 | stack], context, line, offset) do
    consume__149(rest, acc, stack, context, line, offset)
  end

  defp consume__148(rest, acc, [count | stack], context, line, offset) do
    consume__147(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__149(rest, acc, stack, context, line, offset) do
    consume__153(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__151(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__150(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__152(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__151(rest, [], stack, context, line, offset)
  end

  defp consume__153(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__154(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__153(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__154(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__153(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__154(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__153(rest, acc, stack, context, line, offset) do
    consume__152(rest, acc, stack, context, line, offset)
  end

  defp consume__154(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__150(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__150(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__137(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__137(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__134(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__155(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__135(rest, [], stack, context, line, offset)
  end

  defp consume__156(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or x0 === 95 do
    consume__157(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__156(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__157(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__156(rest, acc, stack, context, line, offset) do
    consume__155(rest, acc, stack, context, line, offset)
  end

  defp consume__157(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__134(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__158(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__156(rest, [], stack, context, line, offset)
  end

  defp consume__159(<<"-", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__160(rest, ["-"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__159(rest, acc, stack, context, line, offset) do
    consume__158(rest, acc, stack, context, line, offset)
  end

  defp consume__160(rest, acc, stack, context, line, offset) do
    consume__186(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__162(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__163(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__162(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__158(rest, acc, stack, context, line, offset)
  end

  defp consume__163(rest, acc, stack, context, line, offset) do
    consume__171(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__165(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__166("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__165(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__158(rest, acc, stack, context, line, offset)
  end

  defp consume__166(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__164(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__167(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__165(rest, [], stack, context, line, offset)
  end

  defp consume__168(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__169(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__168(rest, acc, stack, context, line, offset) do
    consume__167(rest, acc, stack, context, line, offset)
  end

  defp consume__169(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__164(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__170(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__168(rest, [], stack, context, line, offset)
  end

  defp consume__171(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__172(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__171(rest, acc, stack, context, line, offset) do
    consume__170(rest, acc, stack, context, line, offset)
  end

  defp consume__172(rest, acc, stack, context, line, offset) do
    consume__174(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__174(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__175(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__174(rest, acc, stack, context, line, offset) do
    consume__173(rest, acc, stack, context, line, offset)
  end

  defp consume__173(rest, acc, [_ | stack], context, line, offset) do
    consume__176(rest, acc, stack, context, line, offset)
  end

  defp consume__175(rest, acc, [1 | stack], context, line, offset) do
    consume__176(rest, acc, stack, context, line, offset)
  end

  defp consume__175(rest, acc, [count | stack], context, line, offset) do
    consume__174(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__176(rest, acc, stack, context, line, offset) do
    consume__180(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__178(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__177(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__179(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__178(rest, [], stack, context, line, offset)
  end

  defp consume__180(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__181(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__180(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__181(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__180(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__181(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__180(rest, acc, stack, context, line, offset) do
    consume__179(rest, acc, stack, context, line, offset)
  end

  defp consume__181(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__177(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__177(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__164(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__164(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__161(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__182(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__162(rest, [], stack, context, line, offset)
  end

  defp consume__183(<<"-", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__184(rest, ["-"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__183(rest, acc, stack, context, line, offset) do
    consume__182(rest, acc, stack, context, line, offset)
  end

  defp consume__184(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__161(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__185(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__183(rest, [], stack, context, line, offset)
  end

  defp consume__186(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or x0 === 95 do
    consume__187(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__186(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__187(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__186(rest, acc, stack, context, line, offset) do
    consume__185(rest, acc, stack, context, line, offset)
  end

  defp consume__187(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__161(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__161(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__134(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__134(rest, acc, stack, context, line, offset) do
    consume__189(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__189(rest, acc, stack, context, line, offset) do
    consume__212(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__191(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__192(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__191(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__188(rest, acc, stack, context, line, offset)
  end

  defp consume__192(rest, acc, stack, context, line, offset) do
    consume__200(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__194(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__195("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__194(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__188(rest, acc, stack, context, line, offset)
  end

  defp consume__195(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__193(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__196(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__194(rest, [], stack, context, line, offset)
  end

  defp consume__197(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__198(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__197(rest, acc, stack, context, line, offset) do
    consume__196(rest, acc, stack, context, line, offset)
  end

  defp consume__198(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__193(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__199(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__197(rest, [], stack, context, line, offset)
  end

  defp consume__200(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__201(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__200(rest, acc, stack, context, line, offset) do
    consume__199(rest, acc, stack, context, line, offset)
  end

  defp consume__201(rest, acc, stack, context, line, offset) do
    consume__203(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__203(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__204(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__203(rest, acc, stack, context, line, offset) do
    consume__202(rest, acc, stack, context, line, offset)
  end

  defp consume__202(rest, acc, [_ | stack], context, line, offset) do
    consume__205(rest, acc, stack, context, line, offset)
  end

  defp consume__204(rest, acc, [1 | stack], context, line, offset) do
    consume__205(rest, acc, stack, context, line, offset)
  end

  defp consume__204(rest, acc, [count | stack], context, line, offset) do
    consume__203(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__205(rest, acc, stack, context, line, offset) do
    consume__209(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__207(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__206(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__208(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__207(rest, [], stack, context, line, offset)
  end

  defp consume__209(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__210(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__209(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__210(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__209(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__210(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__209(rest, acc, stack, context, line, offset) do
    consume__208(rest, acc, stack, context, line, offset)
  end

  defp consume__210(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__206(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__206(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__193(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__193(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__190(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__211(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__191(rest, [], stack, context, line, offset)
  end

  defp consume__212(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    consume__213(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__212(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__213(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__212(rest, acc, stack, context, line, offset) do
    consume__211(rest, acc, stack, context, line, offset)
  end

  defp consume__213(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__190(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__188(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__214(rest, acc, stack, context, line, offset)
  end

  defp consume__190(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__189(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__214(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__215(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__215(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__216(
      rest,
      [
        ident:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__216(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__217(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__131(rest, [], stack, context, line, offset)
  end

  defp consume__218(rest, acc, stack, context, line, offset) do
    consume__219(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__219(rest, acc, stack, context, line, offset) do
    consume__220(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__220(rest, acc, stack, context, line, offset) do
    consume__221(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__221(rest, acc, stack, context, line, offset) do
    consume__247(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__223(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__224(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__223(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    consume__217(rest, acc, stack, context, line, offset)
  end

  defp consume__224(rest, acc, stack, context, line, offset) do
    consume__232(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__226(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__227("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__226(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, _, _, acc | stack] = stack
    consume__217(rest, acc, stack, context, line, offset)
  end

  defp consume__227(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__225(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__228(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__226(rest, [], stack, context, line, offset)
  end

  defp consume__229(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__230(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__229(rest, acc, stack, context, line, offset) do
    consume__228(rest, acc, stack, context, line, offset)
  end

  defp consume__230(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__225(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__231(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__229(rest, [], stack, context, line, offset)
  end

  defp consume__232(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__233(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__232(rest, acc, stack, context, line, offset) do
    consume__231(rest, acc, stack, context, line, offset)
  end

  defp consume__233(rest, acc, stack, context, line, offset) do
    consume__235(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__235(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__236(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__235(rest, acc, stack, context, line, offset) do
    consume__234(rest, acc, stack, context, line, offset)
  end

  defp consume__234(rest, acc, [_ | stack], context, line, offset) do
    consume__237(rest, acc, stack, context, line, offset)
  end

  defp consume__236(rest, acc, [1 | stack], context, line, offset) do
    consume__237(rest, acc, stack, context, line, offset)
  end

  defp consume__236(rest, acc, [count | stack], context, line, offset) do
    consume__235(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__237(rest, acc, stack, context, line, offset) do
    consume__241(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__239(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__238(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__240(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__239(rest, [], stack, context, line, offset)
  end

  defp consume__241(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__242(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__241(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__242(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__241(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__242(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__241(rest, acc, stack, context, line, offset) do
    consume__240(rest, acc, stack, context, line, offset)
  end

  defp consume__242(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__238(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__238(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__225(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__225(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__222(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__243(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__223(rest, [], stack, context, line, offset)
  end

  defp consume__244(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or x0 === 95 do
    consume__245(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__244(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__245(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__244(rest, acc, stack, context, line, offset) do
    consume__243(rest, acc, stack, context, line, offset)
  end

  defp consume__245(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__222(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__246(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__244(rest, [], stack, context, line, offset)
  end

  defp consume__247(<<"-", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__248(rest, ["-"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__247(rest, acc, stack, context, line, offset) do
    consume__246(rest, acc, stack, context, line, offset)
  end

  defp consume__248(rest, acc, stack, context, line, offset) do
    consume__274(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__250(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__251(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__250(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__246(rest, acc, stack, context, line, offset)
  end

  defp consume__251(rest, acc, stack, context, line, offset) do
    consume__259(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__253(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__254("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__253(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__246(rest, acc, stack, context, line, offset)
  end

  defp consume__254(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__252(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__255(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__253(rest, [], stack, context, line, offset)
  end

  defp consume__256(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__257(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__256(rest, acc, stack, context, line, offset) do
    consume__255(rest, acc, stack, context, line, offset)
  end

  defp consume__257(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__252(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__258(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__256(rest, [], stack, context, line, offset)
  end

  defp consume__259(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__260(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__259(rest, acc, stack, context, line, offset) do
    consume__258(rest, acc, stack, context, line, offset)
  end

  defp consume__260(rest, acc, stack, context, line, offset) do
    consume__262(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__262(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__263(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__262(rest, acc, stack, context, line, offset) do
    consume__261(rest, acc, stack, context, line, offset)
  end

  defp consume__261(rest, acc, [_ | stack], context, line, offset) do
    consume__264(rest, acc, stack, context, line, offset)
  end

  defp consume__263(rest, acc, [1 | stack], context, line, offset) do
    consume__264(rest, acc, stack, context, line, offset)
  end

  defp consume__263(rest, acc, [count | stack], context, line, offset) do
    consume__262(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__264(rest, acc, stack, context, line, offset) do
    consume__268(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__266(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__265(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__267(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__266(rest, [], stack, context, line, offset)
  end

  defp consume__268(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__269(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__268(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__269(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__268(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__269(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__268(rest, acc, stack, context, line, offset) do
    consume__267(rest, acc, stack, context, line, offset)
  end

  defp consume__269(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__265(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__265(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__252(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__252(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__249(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__270(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__250(rest, [], stack, context, line, offset)
  end

  defp consume__271(<<"-", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__272(rest, ["-"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__271(rest, acc, stack, context, line, offset) do
    consume__270(rest, acc, stack, context, line, offset)
  end

  defp consume__272(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__249(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__273(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__271(rest, [], stack, context, line, offset)
  end

  defp consume__274(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or x0 === 95 do
    consume__275(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__274(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__275(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__274(rest, acc, stack, context, line, offset) do
    consume__273(rest, acc, stack, context, line, offset)
  end

  defp consume__275(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__249(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__249(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__222(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__222(rest, acc, stack, context, line, offset) do
    consume__277(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__277(rest, acc, stack, context, line, offset) do
    consume__300(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__279(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__280(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__279(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__276(rest, acc, stack, context, line, offset)
  end

  defp consume__280(rest, acc, stack, context, line, offset) do
    consume__288(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__282(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__283("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__282(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__276(rest, acc, stack, context, line, offset)
  end

  defp consume__283(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__281(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__284(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__282(rest, [], stack, context, line, offset)
  end

  defp consume__285(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__286(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__285(rest, acc, stack, context, line, offset) do
    consume__284(rest, acc, stack, context, line, offset)
  end

  defp consume__286(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__281(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__287(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__285(rest, [], stack, context, line, offset)
  end

  defp consume__288(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__289(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__288(rest, acc, stack, context, line, offset) do
    consume__287(rest, acc, stack, context, line, offset)
  end

  defp consume__289(rest, acc, stack, context, line, offset) do
    consume__291(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__291(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__292(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__291(rest, acc, stack, context, line, offset) do
    consume__290(rest, acc, stack, context, line, offset)
  end

  defp consume__290(rest, acc, [_ | stack], context, line, offset) do
    consume__293(rest, acc, stack, context, line, offset)
  end

  defp consume__292(rest, acc, [1 | stack], context, line, offset) do
    consume__293(rest, acc, stack, context, line, offset)
  end

  defp consume__292(rest, acc, [count | stack], context, line, offset) do
    consume__291(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__293(rest, acc, stack, context, line, offset) do
    consume__297(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__295(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__294(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__296(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__295(rest, [], stack, context, line, offset)
  end

  defp consume__297(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__298(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__297(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__298(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__297(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__298(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__297(rest, acc, stack, context, line, offset) do
    consume__296(rest, acc, stack, context, line, offset)
  end

  defp consume__298(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__294(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__294(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__281(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__281(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__278(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__299(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__279(rest, [], stack, context, line, offset)
  end

  defp consume__300(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    consume__301(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__300(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__301(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__300(rest, acc, stack, context, line, offset) do
    consume__299(rest, acc, stack, context, line, offset)
  end

  defp consume__301(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__278(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__276(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__302(rest, acc, stack, context, line, offset)
  end

  defp consume__278(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__277(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__302(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__303(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__303(<<"(", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__304(rest, ["("] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__303(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__217(rest, acc, stack, context, line, offset)
  end

  defp consume__304(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__305(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__305(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__306(
      rest,
      [
        function:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__306(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__307(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__218(rest, [], stack, context, line, offset)
  end

  defp consume__308(rest, acc, stack, context, line, offset) do
    consume__309(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__309(rest, acc, stack, context, line, offset) do
    consume__310(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__310(rest, acc, stack, context, line, offset) do
    consume__328(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__312(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__313(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__312(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__307(rest, acc, stack, context, line, offset)
  end

  defp consume__313(rest, acc, stack, context, line, offset) do
    consume__315(rest, acc, [4 | stack], context, line, offset)
  end

  defp consume__315(<<"0", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__316(rest, ["0"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__315(rest, acc, stack, context, line, offset) do
    consume__314(rest, acc, stack, context, line, offset)
  end

  defp consume__314(rest, acc, [_ | stack], context, line, offset) do
    consume__317(rest, acc, stack, context, line, offset)
  end

  defp consume__316(rest, acc, [1 | stack], context, line, offset) do
    consume__317(rest, acc, stack, context, line, offset)
  end

  defp consume__316(rest, acc, [count | stack], context, line, offset) do
    consume__315(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__317(<<"75", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__318(rest, ["75"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__317(<<"55", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__318(rest, ["55"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__317(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__307(rest, acc, stack, context, line, offset)
  end

  defp consume__318(rest, acc, stack, context, line, offset) do
    consume__322(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__320(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__319(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__321(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__320(rest, [], stack, context, line, offset)
  end

  defp consume__322(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__323(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__322(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__323(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__322(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__323(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__322(rest, acc, stack, context, line, offset) do
    consume__321(rest, acc, stack, context, line, offset)
  end

  defp consume__323(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__319(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__319(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__311(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__324(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__312(rest, [], stack, context, line, offset)
  end

  defp consume__325(<<"\\", x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 117 or x0 === 85 do
    consume__326(
      rest,
      [<<x0::integer>>, "\\"] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp consume__325(rest, acc, stack, context, line, offset) do
    consume__324(rest, acc, stack, context, line, offset)
  end

  defp consume__326(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__311(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__327(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__325(rest, [], stack, context, line, offset)
  end

  defp consume__328(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 117 or x0 === 85 do
    consume__329(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__328(rest, acc, stack, context, line, offset) do
    consume__327(rest, acc, stack, context, line, offset)
  end

  defp consume__329(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__311(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__311(rest, acc, stack, context, line, offset) do
    consume__347(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__331(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__332(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__331(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__307(rest, acc, stack, context, line, offset)
  end

  defp consume__332(rest, acc, stack, context, line, offset) do
    consume__334(rest, acc, [4 | stack], context, line, offset)
  end

  defp consume__334(<<"0", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__335(rest, ["0"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__334(rest, acc, stack, context, line, offset) do
    consume__333(rest, acc, stack, context, line, offset)
  end

  defp consume__333(rest, acc, [_ | stack], context, line, offset) do
    consume__336(rest, acc, stack, context, line, offset)
  end

  defp consume__335(rest, acc, [1 | stack], context, line, offset) do
    consume__336(rest, acc, stack, context, line, offset)
  end

  defp consume__335(rest, acc, [count | stack], context, line, offset) do
    consume__334(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__336(<<"72", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__337(rest, ["72"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__336(<<"52", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__337(rest, ["52"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__336(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__307(rest, acc, stack, context, line, offset)
  end

  defp consume__337(rest, acc, stack, context, line, offset) do
    consume__341(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__339(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__338(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__340(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__339(rest, [], stack, context, line, offset)
  end

  defp consume__341(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__342(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__341(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__342(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__341(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__342(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__341(rest, acc, stack, context, line, offset) do
    consume__340(rest, acc, stack, context, line, offset)
  end

  defp consume__342(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__338(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__338(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__330(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__343(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__331(rest, [], stack, context, line, offset)
  end

  defp consume__344(<<"\\", x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 114 or x0 === 82 do
    consume__345(
      rest,
      [<<x0::integer>>, "\\"] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp consume__344(rest, acc, stack, context, line, offset) do
    consume__343(rest, acc, stack, context, line, offset)
  end

  defp consume__345(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__330(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__346(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__344(rest, [], stack, context, line, offset)
  end

  defp consume__347(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 114 or x0 === 82 do
    consume__348(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__347(rest, acc, stack, context, line, offset) do
    consume__346(rest, acc, stack, context, line, offset)
  end

  defp consume__348(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__330(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__330(rest, acc, stack, context, line, offset) do
    consume__366(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__350(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__351(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__350(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__307(rest, acc, stack, context, line, offset)
  end

  defp consume__351(rest, acc, stack, context, line, offset) do
    consume__353(rest, acc, [4 | stack], context, line, offset)
  end

  defp consume__353(<<"0", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__354(rest, ["0"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__353(rest, acc, stack, context, line, offset) do
    consume__352(rest, acc, stack, context, line, offset)
  end

  defp consume__352(rest, acc, [_ | stack], context, line, offset) do
    consume__355(rest, acc, stack, context, line, offset)
  end

  defp consume__354(rest, acc, [1 | stack], context, line, offset) do
    consume__355(rest, acc, stack, context, line, offset)
  end

  defp consume__354(rest, acc, [count | stack], context, line, offset) do
    consume__353(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__355(<<"6c", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__356(rest, ["6c"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__355(<<"6C", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__356(rest, ["6C"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__355(<<"4c", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__356(rest, ["4c"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__355(<<"4C", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__356(rest, ["4C"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__355(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__307(rest, acc, stack, context, line, offset)
  end

  defp consume__356(rest, acc, stack, context, line, offset) do
    consume__360(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__358(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__357(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__359(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__358(rest, [], stack, context, line, offset)
  end

  defp consume__360(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__361(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__360(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__361(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__360(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__361(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__360(rest, acc, stack, context, line, offset) do
    consume__359(rest, acc, stack, context, line, offset)
  end

  defp consume__361(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__357(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__357(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__349(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__362(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__350(rest, [], stack, context, line, offset)
  end

  defp consume__363(<<"\\", x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 108 or x0 === 76 do
    consume__364(
      rest,
      [<<x0::integer>>, "\\"] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp consume__363(rest, acc, stack, context, line, offset) do
    consume__362(rest, acc, stack, context, line, offset)
  end

  defp consume__364(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__349(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__365(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__363(rest, [], stack, context, line, offset)
  end

  defp consume__366(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 108 or x0 === 76 do
    consume__367(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__366(rest, acc, stack, context, line, offset) do
    consume__365(rest, acc, stack, context, line, offset)
  end

  defp consume__367(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__349(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__349(<<"(", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__368(rest, ["("] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__349(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__307(rest, acc, stack, context, line, offset)
  end

  defp consume__368(rest, acc, stack, context, line, offset) do
    consume__370(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__370(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__371(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__370(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__371(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__370(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__371(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__370(rest, acc, stack, context, line, offset) do
    consume__369(rest, acc, stack, context, line, offset)
  end

  defp consume__369(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__372(rest, acc, stack, context, line, offset)
  end

  defp consume__371(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__370(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__372(<<x0, _::binary>> = rest, _acc, stack, context, line, offset)
       when x0 === 34 or x0 === 39 do
    [_, acc | stack] = stack
    consume__307(rest, acc, stack, context, line, offset)
  end

  defp consume__372(rest, acc, stack, context, line, offset) do
    consume__373(rest, acc, stack, context, line, offset)
  end

  defp consume__373(rest, acc, stack, context, line, offset) do
    consume__375(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__375(rest, acc, stack, context, line, offset) do
    consume__387(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__377(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__378(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__377(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__374(rest, acc, stack, context, line, offset)
  end

  defp consume__378(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__376(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__379(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__377(rest, [], stack, context, line, offset)
  end

  defp consume__380(rest, acc, stack, context, line, offset) do
    consume__381(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__381(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 41 and x0 !== 92 do
    consume__382(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__381(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__379(rest, acc, stack, context, line, offset)
  end

  defp consume__382(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 41 and x0 !== 92 do
    consume__384(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__382(rest, acc, stack, context, line, offset) do
    consume__383(rest, acc, stack, context, line, offset)
  end

  defp consume__384(rest, acc, stack, context, line, offset) do
    consume__382(rest, acc, stack, context, line, offset)
  end

  defp consume__383(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__385(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__385(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__376(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__386(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__380(rest, [], stack, context, line, offset)
  end

  defp consume__387(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__388(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__387(rest, acc, stack, context, line, offset) do
    consume__386(rest, acc, stack, context, line, offset)
  end

  defp consume__388(rest, acc, stack, context, line, offset) do
    consume__396(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__390(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__391("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__390(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__386(rest, acc, stack, context, line, offset)
  end

  defp consume__391(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__389(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__392(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__390(rest, [], stack, context, line, offset)
  end

  defp consume__393(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__394(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__393(rest, acc, stack, context, line, offset) do
    consume__392(rest, acc, stack, context, line, offset)
  end

  defp consume__394(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__389(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__395(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__393(rest, [], stack, context, line, offset)
  end

  defp consume__396(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__397(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__396(rest, acc, stack, context, line, offset) do
    consume__395(rest, acc, stack, context, line, offset)
  end

  defp consume__397(rest, acc, stack, context, line, offset) do
    consume__399(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__399(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__400(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__399(rest, acc, stack, context, line, offset) do
    consume__398(rest, acc, stack, context, line, offset)
  end

  defp consume__398(rest, acc, [_ | stack], context, line, offset) do
    consume__401(rest, acc, stack, context, line, offset)
  end

  defp consume__400(rest, acc, [1 | stack], context, line, offset) do
    consume__401(rest, acc, stack, context, line, offset)
  end

  defp consume__400(rest, acc, [count | stack], context, line, offset) do
    consume__399(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__401(rest, acc, stack, context, line, offset) do
    consume__405(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__403(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__402(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__404(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__403(rest, [], stack, context, line, offset)
  end

  defp consume__405(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__406(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__405(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__406(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__405(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__406(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__405(rest, acc, stack, context, line, offset) do
    consume__404(rest, acc, stack, context, line, offset)
  end

  defp consume__406(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__402(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__402(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__389(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__389(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__376(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__374(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__407(rest, acc, stack, context, line, offset)
  end

  defp consume__376(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__375(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__407(<<")", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__408(rest, [")"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__407(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__408("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__407(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__307(rest, acc, stack, context, line, offset)
  end

  defp consume__408(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__409(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__409(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__410(
      rest,
      [
        bad_url:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__410(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__411(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__308(rest, [], stack, context, line, offset)
  end

  defp consume__412(rest, acc, stack, context, line, offset) do
    consume__413(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__413(rest, acc, stack, context, line, offset) do
    consume__414(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__414(rest, acc, stack, context, line, offset) do
    consume__432(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__416(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__417(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__416(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__411(rest, acc, stack, context, line, offset)
  end

  defp consume__417(rest, acc, stack, context, line, offset) do
    consume__419(rest, acc, [4 | stack], context, line, offset)
  end

  defp consume__419(<<"0", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__420(rest, ["0"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__419(rest, acc, stack, context, line, offset) do
    consume__418(rest, acc, stack, context, line, offset)
  end

  defp consume__418(rest, acc, [_ | stack], context, line, offset) do
    consume__421(rest, acc, stack, context, line, offset)
  end

  defp consume__420(rest, acc, [1 | stack], context, line, offset) do
    consume__421(rest, acc, stack, context, line, offset)
  end

  defp consume__420(rest, acc, [count | stack], context, line, offset) do
    consume__419(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__421(<<"75", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__422(rest, ["75"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__421(<<"55", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__422(rest, ["55"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__421(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__411(rest, acc, stack, context, line, offset)
  end

  defp consume__422(rest, acc, stack, context, line, offset) do
    consume__426(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__424(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__423(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__425(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__424(rest, [], stack, context, line, offset)
  end

  defp consume__426(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__427(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__426(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__427(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__426(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__427(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__426(rest, acc, stack, context, line, offset) do
    consume__425(rest, acc, stack, context, line, offset)
  end

  defp consume__427(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__423(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__423(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__415(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__428(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__416(rest, [], stack, context, line, offset)
  end

  defp consume__429(<<"\\", x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 117 or x0 === 85 do
    consume__430(
      rest,
      [<<x0::integer>>, "\\"] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp consume__429(rest, acc, stack, context, line, offset) do
    consume__428(rest, acc, stack, context, line, offset)
  end

  defp consume__430(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__415(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__431(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__429(rest, [], stack, context, line, offset)
  end

  defp consume__432(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 117 or x0 === 85 do
    consume__433(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__432(rest, acc, stack, context, line, offset) do
    consume__431(rest, acc, stack, context, line, offset)
  end

  defp consume__433(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__415(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__415(rest, acc, stack, context, line, offset) do
    consume__451(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__435(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__436(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__435(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__411(rest, acc, stack, context, line, offset)
  end

  defp consume__436(rest, acc, stack, context, line, offset) do
    consume__438(rest, acc, [4 | stack], context, line, offset)
  end

  defp consume__438(<<"0", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__439(rest, ["0"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__438(rest, acc, stack, context, line, offset) do
    consume__437(rest, acc, stack, context, line, offset)
  end

  defp consume__437(rest, acc, [_ | stack], context, line, offset) do
    consume__440(rest, acc, stack, context, line, offset)
  end

  defp consume__439(rest, acc, [1 | stack], context, line, offset) do
    consume__440(rest, acc, stack, context, line, offset)
  end

  defp consume__439(rest, acc, [count | stack], context, line, offset) do
    consume__438(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__440(<<"72", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__441(rest, ["72"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__440(<<"52", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__441(rest, ["52"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__440(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__411(rest, acc, stack, context, line, offset)
  end

  defp consume__441(rest, acc, stack, context, line, offset) do
    consume__445(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__443(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__442(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__444(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__443(rest, [], stack, context, line, offset)
  end

  defp consume__445(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__446(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__445(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__446(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__445(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__446(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__445(rest, acc, stack, context, line, offset) do
    consume__444(rest, acc, stack, context, line, offset)
  end

  defp consume__446(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__442(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__442(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__434(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__447(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__435(rest, [], stack, context, line, offset)
  end

  defp consume__448(<<"\\", x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 114 or x0 === 82 do
    consume__449(
      rest,
      [<<x0::integer>>, "\\"] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp consume__448(rest, acc, stack, context, line, offset) do
    consume__447(rest, acc, stack, context, line, offset)
  end

  defp consume__449(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__434(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__450(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__448(rest, [], stack, context, line, offset)
  end

  defp consume__451(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 114 or x0 === 82 do
    consume__452(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__451(rest, acc, stack, context, line, offset) do
    consume__450(rest, acc, stack, context, line, offset)
  end

  defp consume__452(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__434(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__434(rest, acc, stack, context, line, offset) do
    consume__470(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__454(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__455(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__454(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__411(rest, acc, stack, context, line, offset)
  end

  defp consume__455(rest, acc, stack, context, line, offset) do
    consume__457(rest, acc, [4 | stack], context, line, offset)
  end

  defp consume__457(<<"0", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__458(rest, ["0"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__457(rest, acc, stack, context, line, offset) do
    consume__456(rest, acc, stack, context, line, offset)
  end

  defp consume__456(rest, acc, [_ | stack], context, line, offset) do
    consume__459(rest, acc, stack, context, line, offset)
  end

  defp consume__458(rest, acc, [1 | stack], context, line, offset) do
    consume__459(rest, acc, stack, context, line, offset)
  end

  defp consume__458(rest, acc, [count | stack], context, line, offset) do
    consume__457(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__459(<<"6c", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__460(rest, ["6c"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__459(<<"6C", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__460(rest, ["6C"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__459(<<"4c", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__460(rest, ["4c"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__459(<<"4C", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__460(rest, ["4C"] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__459(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__411(rest, acc, stack, context, line, offset)
  end

  defp consume__460(rest, acc, stack, context, line, offset) do
    consume__464(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__462(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__461(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__463(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__462(rest, [], stack, context, line, offset)
  end

  defp consume__464(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__465(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__464(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__465(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__464(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__465(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__464(rest, acc, stack, context, line, offset) do
    consume__463(rest, acc, stack, context, line, offset)
  end

  defp consume__465(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__461(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__461(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__453(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__466(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__454(rest, [], stack, context, line, offset)
  end

  defp consume__467(<<"\\", x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 108 or x0 === 76 do
    consume__468(
      rest,
      [<<x0::integer>>, "\\"] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp consume__467(rest, acc, stack, context, line, offset) do
    consume__466(rest, acc, stack, context, line, offset)
  end

  defp consume__468(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__453(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__469(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__467(rest, [], stack, context, line, offset)
  end

  defp consume__470(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 108 or x0 === 76 do
    consume__471(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__470(rest, acc, stack, context, line, offset) do
    consume__469(rest, acc, stack, context, line, offset)
  end

  defp consume__471(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__453(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__453(<<"(", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__472(rest, ["("] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__453(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__411(rest, acc, stack, context, line, offset)
  end

  defp consume__472(rest, acc, stack, context, line, offset) do
    consume__474(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__474(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__475(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__474(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__475(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__474(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__475(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__474(rest, acc, stack, context, line, offset) do
    consume__473(rest, acc, stack, context, line, offset)
  end

  defp consume__473(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__476(rest, acc, stack, context, line, offset)
  end

  defp consume__475(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__474(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__476(rest, acc, stack, context, line, offset) do
    consume__478(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__478(rest, acc, stack, context, line, offset) do
    consume__501(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__480(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__481(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__480(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__477(rest, acc, stack, context, line, offset)
  end

  defp consume__481(rest, acc, stack, context, line, offset) do
    consume__489(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__483(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__484("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__483(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__477(rest, acc, stack, context, line, offset)
  end

  defp consume__484(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__482(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__485(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__483(rest, [], stack, context, line, offset)
  end

  defp consume__486(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__487(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__486(rest, acc, stack, context, line, offset) do
    consume__485(rest, acc, stack, context, line, offset)
  end

  defp consume__487(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__482(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__488(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__486(rest, [], stack, context, line, offset)
  end

  defp consume__489(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__490(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__489(rest, acc, stack, context, line, offset) do
    consume__488(rest, acc, stack, context, line, offset)
  end

  defp consume__490(rest, acc, stack, context, line, offset) do
    consume__492(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__492(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__493(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__492(rest, acc, stack, context, line, offset) do
    consume__491(rest, acc, stack, context, line, offset)
  end

  defp consume__491(rest, acc, [_ | stack], context, line, offset) do
    consume__494(rest, acc, stack, context, line, offset)
  end

  defp consume__493(rest, acc, [1 | stack], context, line, offset) do
    consume__494(rest, acc, stack, context, line, offset)
  end

  defp consume__493(rest, acc, [count | stack], context, line, offset) do
    consume__492(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__494(rest, acc, stack, context, line, offset) do
    consume__498(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__496(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__495(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__497(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__496(rest, [], stack, context, line, offset)
  end

  defp consume__498(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__499(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__498(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__499(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__498(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__499(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__498(rest, acc, stack, context, line, offset) do
    consume__497(rest, acc, stack, context, line, offset)
  end

  defp consume__499(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__495(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__495(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__482(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__482(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__479(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__500(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__480(rest, [], stack, context, line, offset)
  end

  defp consume__501(rest, acc, stack, context, line, offset) do
    consume__502(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__502(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 and x0 !== 39 and x0 !== 40 and x0 !== 41 and x0 !== 92 and x0 !== 32 and
              x0 !== 9 and
              x0 !== 10 and (x0 < 0 or x0 > 8) and x0 !== 11 and (x0 < 14 or x0 > 31) and
              x0 !== 127 do
    consume__503(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__502(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__500(rest, acc, stack, context, line, offset)
  end

  defp consume__503(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 and x0 !== 39 and x0 !== 40 and x0 !== 41 and x0 !== 92 and x0 !== 32 and
              x0 !== 9 and
              x0 !== 10 and (x0 < 0 or x0 > 8) and x0 !== 11 and (x0 < 14 or x0 > 31) and
              x0 !== 127 do
    consume__505(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__503(rest, acc, stack, context, line, offset) do
    consume__504(rest, acc, stack, context, line, offset)
  end

  defp consume__505(rest, acc, stack, context, line, offset) do
    consume__503(rest, acc, stack, context, line, offset)
  end

  defp consume__504(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__506(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__506(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__479(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__477(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__507(rest, acc, stack, context, line, offset)
  end

  defp consume__479(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__478(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__507(rest, acc, stack, context, line, offset) do
    consume__509(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__509(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__510(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__509(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__510(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__509(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__510(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__509(rest, acc, stack, context, line, offset) do
    consume__508(rest, acc, stack, context, line, offset)
  end

  defp consume__508(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__511(rest, acc, stack, context, line, offset)
  end

  defp consume__510(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__509(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__511(<<")", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__512(rest, [")"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__511(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__512("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__511(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__411(rest, acc, stack, context, line, offset)
  end

  defp consume__512(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__513(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__513(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__514(
      rest,
      [
        url:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__514(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__515(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__412(rest, [], stack, context, line, offset)
  end

  defp consume__516(<<"-->", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__517(rest, [cdc: "-->"] ++ acc, stack, context, comb__line, comb__offset + 3)
  end

  defp consume__516(rest, acc, stack, context, line, offset) do
    consume__515(rest, acc, stack, context, line, offset)
  end

  defp consume__517(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__518(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__516(rest, [], stack, context, line, offset)
  end

  defp consume__519(rest, acc, stack, context, line, offset) do
    consume__520(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__520(rest, acc, stack, context, line, offset) do
    consume__521(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__521(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 43 or x0 === 45 do
    consume__522(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__521(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__522(rest, [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__522(rest, acc, stack, context, line, offset) do
    consume__539(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__524(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__525(rest, ["."] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__524(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__518(rest, acc, stack, context, line, offset)
  end

  defp consume__525(rest, acc, stack, context, line, offset) do
    consume__526(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__526(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__527(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__526(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    consume__518(rest, acc, stack, context, line, offset)
  end

  defp consume__527(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__529(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__527(rest, acc, stack, context, line, offset) do
    consume__528(rest, acc, stack, context, line, offset)
  end

  defp consume__529(rest, acc, stack, context, line, offset) do
    consume__527(rest, acc, stack, context, line, offset)
  end

  defp consume__528(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__530(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__530(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__523(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__531(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__524(rest, [], stack, context, line, offset)
  end

  defp consume__532(rest, acc, stack, context, line, offset) do
    consume__533(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__533(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__534(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__533(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__531(rest, acc, stack, context, line, offset)
  end

  defp consume__534(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__536(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__534(rest, acc, stack, context, line, offset) do
    consume__535(rest, acc, stack, context, line, offset)
  end

  defp consume__536(rest, acc, stack, context, line, offset) do
    consume__534(rest, acc, stack, context, line, offset)
  end

  defp consume__535(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__537(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__537(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__523(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__538(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__532(rest, [], stack, context, line, offset)
  end

  defp consume__539(rest, acc, stack, context, line, offset) do
    consume__540(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__540(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__541(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__540(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__538(rest, acc, stack, context, line, offset)
  end

  defp consume__541(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__543(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__541(rest, acc, stack, context, line, offset) do
    consume__542(rest, acc, stack, context, line, offset)
  end

  defp consume__543(rest, acc, stack, context, line, offset) do
    consume__541(rest, acc, stack, context, line, offset)
  end

  defp consume__542(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__544(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__544(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__545(rest, ["."] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__544(rest, acc, stack, context, line, offset) do
    consume__538(rest, acc, stack, context, line, offset)
  end

  defp consume__545(rest, acc, stack, context, line, offset) do
    consume__546(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__546(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__547(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__546(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__538(rest, acc, stack, context, line, offset)
  end

  defp consume__547(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__549(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__547(rest, acc, stack, context, line, offset) do
    consume__548(rest, acc, stack, context, line, offset)
  end

  defp consume__549(rest, acc, stack, context, line, offset) do
    consume__547(rest, acc, stack, context, line, offset)
  end

  defp consume__548(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__550(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__550(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__523(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__523(rest, acc, stack, context, line, offset) do
    consume__554(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__552(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__551(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__553(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__552(rest, [], stack, context, line, offset)
  end

  defp consume__554(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 101 or x0 === 69 do
    consume__555(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__554(rest, acc, stack, context, line, offset) do
    consume__553(rest, acc, stack, context, line, offset)
  end

  defp consume__555(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 43 or x0 === 45 do
    consume__556(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__555(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__556(rest, [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__556(rest, acc, stack, context, line, offset) do
    consume__557(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__557(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__558(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__557(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__553(rest, acc, stack, context, line, offset)
  end

  defp consume__558(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__560(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__558(rest, acc, stack, context, line, offset) do
    consume__559(rest, acc, stack, context, line, offset)
  end

  defp consume__560(rest, acc, stack, context, line, offset) do
    consume__558(rest, acc, stack, context, line, offset)
  end

  defp consume__559(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__561(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__561(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__551(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__551(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__562(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__562(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__563(
      rest,
      [
        number:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__563(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__564(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__519(rest, [], stack, context, line, offset)
  end

  defp consume__565(rest, acc, stack, context, line, offset) do
    consume__566(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__566(rest, acc, stack, context, line, offset) do
    consume__567(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__567(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 43 or x0 === 45 do
    consume__568(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__567(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__568(rest, [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__568(rest, acc, stack, context, line, offset) do
    consume__585(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__570(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__571(rest, ["."] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__570(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__564(rest, acc, stack, context, line, offset)
  end

  defp consume__571(rest, acc, stack, context, line, offset) do
    consume__572(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__572(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__573(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__572(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    consume__564(rest, acc, stack, context, line, offset)
  end

  defp consume__573(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__575(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__573(rest, acc, stack, context, line, offset) do
    consume__574(rest, acc, stack, context, line, offset)
  end

  defp consume__575(rest, acc, stack, context, line, offset) do
    consume__573(rest, acc, stack, context, line, offset)
  end

  defp consume__574(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__576(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__576(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__569(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__577(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__570(rest, [], stack, context, line, offset)
  end

  defp consume__578(rest, acc, stack, context, line, offset) do
    consume__579(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__579(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__580(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__579(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__577(rest, acc, stack, context, line, offset)
  end

  defp consume__580(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__582(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__580(rest, acc, stack, context, line, offset) do
    consume__581(rest, acc, stack, context, line, offset)
  end

  defp consume__582(rest, acc, stack, context, line, offset) do
    consume__580(rest, acc, stack, context, line, offset)
  end

  defp consume__581(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__583(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__583(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__569(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__584(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__578(rest, [], stack, context, line, offset)
  end

  defp consume__585(rest, acc, stack, context, line, offset) do
    consume__586(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__586(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__587(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__586(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__584(rest, acc, stack, context, line, offset)
  end

  defp consume__587(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__589(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__587(rest, acc, stack, context, line, offset) do
    consume__588(rest, acc, stack, context, line, offset)
  end

  defp consume__589(rest, acc, stack, context, line, offset) do
    consume__587(rest, acc, stack, context, line, offset)
  end

  defp consume__588(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__590(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__590(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__591(rest, ["."] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__590(rest, acc, stack, context, line, offset) do
    consume__584(rest, acc, stack, context, line, offset)
  end

  defp consume__591(rest, acc, stack, context, line, offset) do
    consume__592(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__592(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__593(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__592(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__584(rest, acc, stack, context, line, offset)
  end

  defp consume__593(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__595(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__593(rest, acc, stack, context, line, offset) do
    consume__594(rest, acc, stack, context, line, offset)
  end

  defp consume__595(rest, acc, stack, context, line, offset) do
    consume__593(rest, acc, stack, context, line, offset)
  end

  defp consume__594(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__596(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__596(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__569(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__569(rest, acc, stack, context, line, offset) do
    consume__600(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__598(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__597(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__599(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__598(rest, [], stack, context, line, offset)
  end

  defp consume__600(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 101 or x0 === 69 do
    consume__601(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__600(rest, acc, stack, context, line, offset) do
    consume__599(rest, acc, stack, context, line, offset)
  end

  defp consume__601(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 43 or x0 === 45 do
    consume__602(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__601(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__602(rest, [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__602(rest, acc, stack, context, line, offset) do
    consume__603(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__603(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__604(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__603(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__599(rest, acc, stack, context, line, offset)
  end

  defp consume__604(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__606(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__604(rest, acc, stack, context, line, offset) do
    consume__605(rest, acc, stack, context, line, offset)
  end

  defp consume__606(rest, acc, stack, context, line, offset) do
    consume__604(rest, acc, stack, context, line, offset)
  end

  defp consume__605(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__607(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__607(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__597(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__597(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__608(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__608(<<"%", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__609(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__608(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__564(rest, acc, stack, context, line, offset)
  end

  defp consume__609(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__610(
      rest,
      [
        percentage:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__610(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__611(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__565(rest, [], stack, context, line, offset)
  end

  defp consume__612(rest, acc, stack, context, line, offset) do
    consume__613(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__613(rest, acc, stack, context, line, offset) do
    consume__614(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__614(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 43 or x0 === 45 do
    consume__615(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__614(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__615(rest, [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__615(rest, acc, stack, context, line, offset) do
    consume__632(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__617(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__618(rest, ["."] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__617(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__611(rest, acc, stack, context, line, offset)
  end

  defp consume__618(rest, acc, stack, context, line, offset) do
    consume__619(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__619(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__620(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__619(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    consume__611(rest, acc, stack, context, line, offset)
  end

  defp consume__620(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__622(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__620(rest, acc, stack, context, line, offset) do
    consume__621(rest, acc, stack, context, line, offset)
  end

  defp consume__622(rest, acc, stack, context, line, offset) do
    consume__620(rest, acc, stack, context, line, offset)
  end

  defp consume__621(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__623(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__623(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__616(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__624(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__617(rest, [], stack, context, line, offset)
  end

  defp consume__625(rest, acc, stack, context, line, offset) do
    consume__626(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__626(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__627(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__626(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__624(rest, acc, stack, context, line, offset)
  end

  defp consume__627(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__629(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__627(rest, acc, stack, context, line, offset) do
    consume__628(rest, acc, stack, context, line, offset)
  end

  defp consume__629(rest, acc, stack, context, line, offset) do
    consume__627(rest, acc, stack, context, line, offset)
  end

  defp consume__628(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__630(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__630(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__616(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__631(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__625(rest, [], stack, context, line, offset)
  end

  defp consume__632(rest, acc, stack, context, line, offset) do
    consume__633(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__633(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__634(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__633(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__631(rest, acc, stack, context, line, offset)
  end

  defp consume__634(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__636(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__634(rest, acc, stack, context, line, offset) do
    consume__635(rest, acc, stack, context, line, offset)
  end

  defp consume__636(rest, acc, stack, context, line, offset) do
    consume__634(rest, acc, stack, context, line, offset)
  end

  defp consume__635(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__637(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__637(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__638(rest, ["."] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__637(rest, acc, stack, context, line, offset) do
    consume__631(rest, acc, stack, context, line, offset)
  end

  defp consume__638(rest, acc, stack, context, line, offset) do
    consume__639(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__639(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__640(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__639(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__631(rest, acc, stack, context, line, offset)
  end

  defp consume__640(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__642(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__640(rest, acc, stack, context, line, offset) do
    consume__641(rest, acc, stack, context, line, offset)
  end

  defp consume__642(rest, acc, stack, context, line, offset) do
    consume__640(rest, acc, stack, context, line, offset)
  end

  defp consume__641(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__643(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__643(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__616(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__616(rest, acc, stack, context, line, offset) do
    consume__647(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__645(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__644(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__646(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__645(rest, [], stack, context, line, offset)
  end

  defp consume__647(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 101 or x0 === 69 do
    consume__648(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__647(rest, acc, stack, context, line, offset) do
    consume__646(rest, acc, stack, context, line, offset)
  end

  defp consume__648(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 43 or x0 === 45 do
    consume__649(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__648(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__649(rest, [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__649(rest, acc, stack, context, line, offset) do
    consume__650(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__650(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__651(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__650(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__646(rest, acc, stack, context, line, offset)
  end

  defp consume__651(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__653(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__651(rest, acc, stack, context, line, offset) do
    consume__652(rest, acc, stack, context, line, offset)
  end

  defp consume__653(rest, acc, stack, context, line, offset) do
    consume__651(rest, acc, stack, context, line, offset)
  end

  defp consume__652(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__654(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__654(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__644(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__644(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__655(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__655(rest, acc, stack, context, line, offset) do
    consume__656(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__656(rest, acc, stack, context, line, offset) do
    consume__682(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__658(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__659(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__658(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__611(rest, acc, stack, context, line, offset)
  end

  defp consume__659(rest, acc, stack, context, line, offset) do
    consume__667(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__661(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__662("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__661(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, _, acc | stack] = stack
    consume__611(rest, acc, stack, context, line, offset)
  end

  defp consume__662(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__660(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__663(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__661(rest, [], stack, context, line, offset)
  end

  defp consume__664(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__665(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__664(rest, acc, stack, context, line, offset) do
    consume__663(rest, acc, stack, context, line, offset)
  end

  defp consume__665(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__660(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__666(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__664(rest, [], stack, context, line, offset)
  end

  defp consume__667(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__668(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__667(rest, acc, stack, context, line, offset) do
    consume__666(rest, acc, stack, context, line, offset)
  end

  defp consume__668(rest, acc, stack, context, line, offset) do
    consume__670(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__670(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__671(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__670(rest, acc, stack, context, line, offset) do
    consume__669(rest, acc, stack, context, line, offset)
  end

  defp consume__669(rest, acc, [_ | stack], context, line, offset) do
    consume__672(rest, acc, stack, context, line, offset)
  end

  defp consume__671(rest, acc, [1 | stack], context, line, offset) do
    consume__672(rest, acc, stack, context, line, offset)
  end

  defp consume__671(rest, acc, [count | stack], context, line, offset) do
    consume__670(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__672(rest, acc, stack, context, line, offset) do
    consume__676(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__674(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__673(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__675(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__674(rest, [], stack, context, line, offset)
  end

  defp consume__676(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__677(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__676(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__677(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__676(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__677(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__676(rest, acc, stack, context, line, offset) do
    consume__675(rest, acc, stack, context, line, offset)
  end

  defp consume__677(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__673(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__673(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__660(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__660(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__657(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__678(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__658(rest, [], stack, context, line, offset)
  end

  defp consume__679(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or x0 === 95 do
    consume__680(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__679(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__680(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__679(rest, acc, stack, context, line, offset) do
    consume__678(rest, acc, stack, context, line, offset)
  end

  defp consume__680(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__657(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__681(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__679(rest, [], stack, context, line, offset)
  end

  defp consume__682(<<"-", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__683(rest, ["-"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__682(rest, acc, stack, context, line, offset) do
    consume__681(rest, acc, stack, context, line, offset)
  end

  defp consume__683(rest, acc, stack, context, line, offset) do
    consume__709(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__685(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__686(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__685(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__681(rest, acc, stack, context, line, offset)
  end

  defp consume__686(rest, acc, stack, context, line, offset) do
    consume__694(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__688(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__689("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__688(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__681(rest, acc, stack, context, line, offset)
  end

  defp consume__689(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__687(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__690(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__688(rest, [], stack, context, line, offset)
  end

  defp consume__691(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__692(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__691(rest, acc, stack, context, line, offset) do
    consume__690(rest, acc, stack, context, line, offset)
  end

  defp consume__692(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__687(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__693(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__691(rest, [], stack, context, line, offset)
  end

  defp consume__694(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__695(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__694(rest, acc, stack, context, line, offset) do
    consume__693(rest, acc, stack, context, line, offset)
  end

  defp consume__695(rest, acc, stack, context, line, offset) do
    consume__697(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__697(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__698(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__697(rest, acc, stack, context, line, offset) do
    consume__696(rest, acc, stack, context, line, offset)
  end

  defp consume__696(rest, acc, [_ | stack], context, line, offset) do
    consume__699(rest, acc, stack, context, line, offset)
  end

  defp consume__698(rest, acc, [1 | stack], context, line, offset) do
    consume__699(rest, acc, stack, context, line, offset)
  end

  defp consume__698(rest, acc, [count | stack], context, line, offset) do
    consume__697(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__699(rest, acc, stack, context, line, offset) do
    consume__703(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__701(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__700(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__702(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__701(rest, [], stack, context, line, offset)
  end

  defp consume__703(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__704(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__703(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__704(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__703(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__704(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__703(rest, acc, stack, context, line, offset) do
    consume__702(rest, acc, stack, context, line, offset)
  end

  defp consume__704(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__700(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__700(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__687(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__687(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__684(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__705(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__685(rest, [], stack, context, line, offset)
  end

  defp consume__706(<<"-", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__707(rest, ["-"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__706(rest, acc, stack, context, line, offset) do
    consume__705(rest, acc, stack, context, line, offset)
  end

  defp consume__707(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__684(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__708(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__706(rest, [], stack, context, line, offset)
  end

  defp consume__709(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or x0 === 95 do
    consume__710(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__709(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__710(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__709(rest, acc, stack, context, line, offset) do
    consume__708(rest, acc, stack, context, line, offset)
  end

  defp consume__710(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__684(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__684(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__657(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__657(rest, acc, stack, context, line, offset) do
    consume__712(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__712(rest, acc, stack, context, line, offset) do
    consume__735(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__714(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__715(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__714(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__711(rest, acc, stack, context, line, offset)
  end

  defp consume__715(rest, acc, stack, context, line, offset) do
    consume__723(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__717(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__718("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__717(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__711(rest, acc, stack, context, line, offset)
  end

  defp consume__718(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__716(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__719(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__717(rest, [], stack, context, line, offset)
  end

  defp consume__720(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__721(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__720(rest, acc, stack, context, line, offset) do
    consume__719(rest, acc, stack, context, line, offset)
  end

  defp consume__721(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__716(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__722(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__720(rest, [], stack, context, line, offset)
  end

  defp consume__723(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__724(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__723(rest, acc, stack, context, line, offset) do
    consume__722(rest, acc, stack, context, line, offset)
  end

  defp consume__724(rest, acc, stack, context, line, offset) do
    consume__726(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__726(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__727(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__726(rest, acc, stack, context, line, offset) do
    consume__725(rest, acc, stack, context, line, offset)
  end

  defp consume__725(rest, acc, [_ | stack], context, line, offset) do
    consume__728(rest, acc, stack, context, line, offset)
  end

  defp consume__727(rest, acc, [1 | stack], context, line, offset) do
    consume__728(rest, acc, stack, context, line, offset)
  end

  defp consume__727(rest, acc, [count | stack], context, line, offset) do
    consume__726(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__728(rest, acc, stack, context, line, offset) do
    consume__732(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__730(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__729(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__731(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__730(rest, [], stack, context, line, offset)
  end

  defp consume__732(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__733(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__732(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__733(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__732(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__733(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__732(rest, acc, stack, context, line, offset) do
    consume__731(rest, acc, stack, context, line, offset)
  end

  defp consume__733(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__729(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__729(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__716(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__716(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__713(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__734(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__714(rest, [], stack, context, line, offset)
  end

  defp consume__735(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    consume__736(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__735(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__736(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__735(rest, acc, stack, context, line, offset) do
    consume__734(rest, acc, stack, context, line, offset)
  end

  defp consume__736(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__713(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__711(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__737(rest, acc, stack, context, line, offset)
  end

  defp consume__713(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__712(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__737(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__738(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__738(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    consume__739(rest, [dimension: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp consume__739(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__740(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__612(rest, [], stack, context, line, offset)
  end

  defp consume__741(rest, acc, stack, context, line, offset) do
    consume__742(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__742(rest, acc, stack, context, line, offset) do
    consume__743(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__743(<<"#", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__744(rest, ["#"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__743(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__740(rest, acc, stack, context, line, offset)
  end

  defp consume__744(rest, acc, stack, context, line, offset) do
    consume__767(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__746(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__747(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__746(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__740(rest, acc, stack, context, line, offset)
  end

  defp consume__747(rest, acc, stack, context, line, offset) do
    consume__755(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__749(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__750("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__749(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, _, acc | stack] = stack
    consume__740(rest, acc, stack, context, line, offset)
  end

  defp consume__750(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__748(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__751(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__749(rest, [], stack, context, line, offset)
  end

  defp consume__752(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__753(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__752(rest, acc, stack, context, line, offset) do
    consume__751(rest, acc, stack, context, line, offset)
  end

  defp consume__753(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__748(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__754(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__752(rest, [], stack, context, line, offset)
  end

  defp consume__755(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__756(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__755(rest, acc, stack, context, line, offset) do
    consume__754(rest, acc, stack, context, line, offset)
  end

  defp consume__756(rest, acc, stack, context, line, offset) do
    consume__758(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__758(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__759(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__758(rest, acc, stack, context, line, offset) do
    consume__757(rest, acc, stack, context, line, offset)
  end

  defp consume__757(rest, acc, [_ | stack], context, line, offset) do
    consume__760(rest, acc, stack, context, line, offset)
  end

  defp consume__759(rest, acc, [1 | stack], context, line, offset) do
    consume__760(rest, acc, stack, context, line, offset)
  end

  defp consume__759(rest, acc, [count | stack], context, line, offset) do
    consume__758(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__760(rest, acc, stack, context, line, offset) do
    consume__764(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__762(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__761(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__763(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__762(rest, [], stack, context, line, offset)
  end

  defp consume__764(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__765(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__764(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__765(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__764(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__765(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__764(rest, acc, stack, context, line, offset) do
    consume__763(rest, acc, stack, context, line, offset)
  end

  defp consume__765(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__761(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__761(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__748(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__748(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__745(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__766(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__746(rest, [], stack, context, line, offset)
  end

  defp consume__767(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    consume__768(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__767(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__768(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__767(rest, acc, stack, context, line, offset) do
    consume__766(rest, acc, stack, context, line, offset)
  end

  defp consume__768(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__745(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__745(rest, acc, stack, context, line, offset) do
    consume__770(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__770(rest, acc, stack, context, line, offset) do
    consume__793(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__772(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__773(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__772(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__769(rest, acc, stack, context, line, offset)
  end

  defp consume__773(rest, acc, stack, context, line, offset) do
    consume__781(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__775(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__776("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__775(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__769(rest, acc, stack, context, line, offset)
  end

  defp consume__776(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__774(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__777(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__775(rest, [], stack, context, line, offset)
  end

  defp consume__778(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__779(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__778(rest, acc, stack, context, line, offset) do
    consume__777(rest, acc, stack, context, line, offset)
  end

  defp consume__779(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__774(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__780(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__778(rest, [], stack, context, line, offset)
  end

  defp consume__781(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__782(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__781(rest, acc, stack, context, line, offset) do
    consume__780(rest, acc, stack, context, line, offset)
  end

  defp consume__782(rest, acc, stack, context, line, offset) do
    consume__784(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__784(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__785(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__784(rest, acc, stack, context, line, offset) do
    consume__783(rest, acc, stack, context, line, offset)
  end

  defp consume__783(rest, acc, [_ | stack], context, line, offset) do
    consume__786(rest, acc, stack, context, line, offset)
  end

  defp consume__785(rest, acc, [1 | stack], context, line, offset) do
    consume__786(rest, acc, stack, context, line, offset)
  end

  defp consume__785(rest, acc, [count | stack], context, line, offset) do
    consume__784(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__786(rest, acc, stack, context, line, offset) do
    consume__790(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__788(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__787(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__789(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__788(rest, [], stack, context, line, offset)
  end

  defp consume__790(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__791(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__790(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__791(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__790(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__791(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__790(rest, acc, stack, context, line, offset) do
    consume__789(rest, acc, stack, context, line, offset)
  end

  defp consume__791(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__787(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__787(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__774(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__774(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__771(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__792(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__772(rest, [], stack, context, line, offset)
  end

  defp consume__793(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    consume__794(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__793(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__794(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__793(rest, acc, stack, context, line, offset) do
    consume__792(rest, acc, stack, context, line, offset)
  end

  defp consume__794(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__771(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__769(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__795(rest, acc, stack, context, line, offset)
  end

  defp consume__771(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__770(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__795(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__796(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__796(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__797(
      rest,
      [
        hash:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__797(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__798(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__741(rest, [], stack, context, line, offset)
  end

  defp consume__799(rest, acc, stack, context, line, offset) do
    consume__800(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__800(rest, acc, stack, context, line, offset) do
    consume__801(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__801(rest, acc, stack, context, line, offset) do
    consume__840(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__803(<<"'", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__804(rest, ["'"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__803(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__798(rest, acc, stack, context, line, offset)
  end

  defp consume__804(rest, acc, stack, context, line, offset) do
    consume__806(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__806(rest, acc, stack, context, line, offset) do
    consume__832(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__808(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__809(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__808(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__805(rest, acc, stack, context, line, offset)
  end

  defp consume__809(rest, acc, stack, context, line, offset) do
    consume__817(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__811(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__812("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__811(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__805(rest, acc, stack, context, line, offset)
  end

  defp consume__812(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__810(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__813(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__811(rest, [], stack, context, line, offset)
  end

  defp consume__814(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__815(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__814(rest, acc, stack, context, line, offset) do
    consume__813(rest, acc, stack, context, line, offset)
  end

  defp consume__815(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__810(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__816(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__814(rest, [], stack, context, line, offset)
  end

  defp consume__817(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__818(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__817(rest, acc, stack, context, line, offset) do
    consume__816(rest, acc, stack, context, line, offset)
  end

  defp consume__818(rest, acc, stack, context, line, offset) do
    consume__820(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__820(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__821(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__820(rest, acc, stack, context, line, offset) do
    consume__819(rest, acc, stack, context, line, offset)
  end

  defp consume__819(rest, acc, [_ | stack], context, line, offset) do
    consume__822(rest, acc, stack, context, line, offset)
  end

  defp consume__821(rest, acc, [1 | stack], context, line, offset) do
    consume__822(rest, acc, stack, context, line, offset)
  end

  defp consume__821(rest, acc, [count | stack], context, line, offset) do
    consume__820(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__822(rest, acc, stack, context, line, offset) do
    consume__826(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__824(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__823(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__825(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__824(rest, [], stack, context, line, offset)
  end

  defp consume__826(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__827(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__826(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__827(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__826(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__827(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__826(rest, acc, stack, context, line, offset) do
    consume__825(rest, acc, stack, context, line, offset)
  end

  defp consume__827(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__823(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__823(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__810(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__810(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__807(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__828(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__808(rest, [], stack, context, line, offset)
  end

  defp consume__829(<<"\\", "\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__830(
      rest,
      ["\n", "\\"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 2},
      comb__offset + 2
    )
  end

  defp consume__829(rest, acc, stack, context, line, offset) do
    consume__828(rest, acc, stack, context, line, offset)
  end

  defp consume__830(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__807(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__831(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__829(rest, [], stack, context, line, offset)
  end

  defp consume__832(rest, acc, stack, context, line, offset) do
    consume__833(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__833(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 39 and x0 !== 92 and x0 !== 10 do
    consume__834(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__833(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__831(rest, acc, stack, context, line, offset)
  end

  defp consume__834(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 39 and x0 !== 92 and x0 !== 10 do
    consume__836(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__834(rest, acc, stack, context, line, offset) do
    consume__835(rest, acc, stack, context, line, offset)
  end

  defp consume__836(rest, acc, stack, context, line, offset) do
    consume__834(rest, acc, stack, context, line, offset)
  end

  defp consume__835(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__837(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__837(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__807(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__805(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__838(rest, acc, stack, context, line, offset)
  end

  defp consume__807(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__806(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__838(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__802(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__839(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__803(rest, [], stack, context, line, offset)
  end

  defp consume__840(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__841(rest, ["\""] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__840(rest, acc, stack, context, line, offset) do
    consume__839(rest, acc, stack, context, line, offset)
  end

  defp consume__841(rest, acc, stack, context, line, offset) do
    consume__843(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__843(rest, acc, stack, context, line, offset) do
    consume__869(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__845(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__846(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__845(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__842(rest, acc, stack, context, line, offset)
  end

  defp consume__846(rest, acc, stack, context, line, offset) do
    consume__854(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__848(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__849("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__848(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__842(rest, acc, stack, context, line, offset)
  end

  defp consume__849(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__847(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__850(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__848(rest, [], stack, context, line, offset)
  end

  defp consume__851(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__852(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__851(rest, acc, stack, context, line, offset) do
    consume__850(rest, acc, stack, context, line, offset)
  end

  defp consume__852(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__847(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__853(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__851(rest, [], stack, context, line, offset)
  end

  defp consume__854(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__855(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__854(rest, acc, stack, context, line, offset) do
    consume__853(rest, acc, stack, context, line, offset)
  end

  defp consume__855(rest, acc, stack, context, line, offset) do
    consume__857(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__857(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__858(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__857(rest, acc, stack, context, line, offset) do
    consume__856(rest, acc, stack, context, line, offset)
  end

  defp consume__856(rest, acc, [_ | stack], context, line, offset) do
    consume__859(rest, acc, stack, context, line, offset)
  end

  defp consume__858(rest, acc, [1 | stack], context, line, offset) do
    consume__859(rest, acc, stack, context, line, offset)
  end

  defp consume__858(rest, acc, [count | stack], context, line, offset) do
    consume__857(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__859(rest, acc, stack, context, line, offset) do
    consume__863(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__861(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__860(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__862(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__861(rest, [], stack, context, line, offset)
  end

  defp consume__863(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__864(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__863(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__864(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__863(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__864(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__863(rest, acc, stack, context, line, offset) do
    consume__862(rest, acc, stack, context, line, offset)
  end

  defp consume__864(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__860(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__860(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__847(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__847(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__844(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__865(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__845(rest, [], stack, context, line, offset)
  end

  defp consume__866(<<"\\", "\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__867(
      rest,
      ["\n", "\\"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 2},
      comb__offset + 2
    )
  end

  defp consume__866(rest, acc, stack, context, line, offset) do
    consume__865(rest, acc, stack, context, line, offset)
  end

  defp consume__867(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__844(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__868(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__866(rest, [], stack, context, line, offset)
  end

  defp consume__869(rest, acc, stack, context, line, offset) do
    consume__870(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__870(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 and x0 !== 92 and x0 !== 10 do
    consume__871(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__870(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__868(rest, acc, stack, context, line, offset)
  end

  defp consume__871(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 and x0 !== 92 and x0 !== 10 do
    consume__873(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__871(rest, acc, stack, context, line, offset) do
    consume__872(rest, acc, stack, context, line, offset)
  end

  defp consume__873(rest, acc, stack, context, line, offset) do
    consume__871(rest, acc, stack, context, line, offset)
  end

  defp consume__872(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__874(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__874(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__844(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__842(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__875(rest, acc, stack, context, line, offset)
  end

  defp consume__844(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__843(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__875(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__802(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__802(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__876(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__876(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__877(
      rest,
      [
        bad_string:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__877(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__878(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__799(rest, [], stack, context, line, offset)
  end

  defp consume__879(rest, acc, stack, context, line, offset) do
    consume__880(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__880(rest, acc, stack, context, line, offset) do
    consume__881(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__881(rest, acc, stack, context, line, offset) do
    consume__921(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__883(<<"'", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__884(rest, ["'"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__883(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__878(rest, acc, stack, context, line, offset)
  end

  defp consume__884(rest, acc, stack, context, line, offset) do
    consume__886(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__886(rest, acc, stack, context, line, offset) do
    consume__912(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__888(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__889(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__888(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__885(rest, acc, stack, context, line, offset)
  end

  defp consume__889(rest, acc, stack, context, line, offset) do
    consume__897(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__891(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__892("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__891(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__885(rest, acc, stack, context, line, offset)
  end

  defp consume__892(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__890(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__893(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__891(rest, [], stack, context, line, offset)
  end

  defp consume__894(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__895(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__894(rest, acc, stack, context, line, offset) do
    consume__893(rest, acc, stack, context, line, offset)
  end

  defp consume__895(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__890(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__896(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__894(rest, [], stack, context, line, offset)
  end

  defp consume__897(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__898(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__897(rest, acc, stack, context, line, offset) do
    consume__896(rest, acc, stack, context, line, offset)
  end

  defp consume__898(rest, acc, stack, context, line, offset) do
    consume__900(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__900(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__901(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__900(rest, acc, stack, context, line, offset) do
    consume__899(rest, acc, stack, context, line, offset)
  end

  defp consume__899(rest, acc, [_ | stack], context, line, offset) do
    consume__902(rest, acc, stack, context, line, offset)
  end

  defp consume__901(rest, acc, [1 | stack], context, line, offset) do
    consume__902(rest, acc, stack, context, line, offset)
  end

  defp consume__901(rest, acc, [count | stack], context, line, offset) do
    consume__900(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__902(rest, acc, stack, context, line, offset) do
    consume__906(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__904(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__903(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__905(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__904(rest, [], stack, context, line, offset)
  end

  defp consume__906(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__907(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__906(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__907(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__906(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__907(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__906(rest, acc, stack, context, line, offset) do
    consume__905(rest, acc, stack, context, line, offset)
  end

  defp consume__907(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__903(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__903(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__890(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__890(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__887(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__908(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__888(rest, [], stack, context, line, offset)
  end

  defp consume__909(<<"\\", "\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__910(
      rest,
      ["\n", "\\"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 2},
      comb__offset + 2
    )
  end

  defp consume__909(rest, acc, stack, context, line, offset) do
    consume__908(rest, acc, stack, context, line, offset)
  end

  defp consume__910(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__887(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__911(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__909(rest, [], stack, context, line, offset)
  end

  defp consume__912(rest, acc, stack, context, line, offset) do
    consume__913(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__913(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 39 and x0 !== 92 and x0 !== 10 do
    consume__914(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__913(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__911(rest, acc, stack, context, line, offset)
  end

  defp consume__914(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 39 and x0 !== 92 and x0 !== 10 do
    consume__916(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__914(rest, acc, stack, context, line, offset) do
    consume__915(rest, acc, stack, context, line, offset)
  end

  defp consume__916(rest, acc, stack, context, line, offset) do
    consume__914(rest, acc, stack, context, line, offset)
  end

  defp consume__915(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__917(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__917(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__887(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__885(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__918(rest, acc, stack, context, line, offset)
  end

  defp consume__887(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__886(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__918(<<"'", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__919(rest, ["'"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__918(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__919("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__918(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__878(rest, acc, stack, context, line, offset)
  end

  defp consume__919(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__882(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__920(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__883(rest, [], stack, context, line, offset)
  end

  defp consume__921(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__922(rest, ["\""] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__921(rest, acc, stack, context, line, offset) do
    consume__920(rest, acc, stack, context, line, offset)
  end

  defp consume__922(rest, acc, stack, context, line, offset) do
    consume__924(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__924(rest, acc, stack, context, line, offset) do
    consume__950(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__926(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__927(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__926(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__923(rest, acc, stack, context, line, offset)
  end

  defp consume__927(rest, acc, stack, context, line, offset) do
    consume__935(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__929(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__930("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__929(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__923(rest, acc, stack, context, line, offset)
  end

  defp consume__930(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__928(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__931(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__929(rest, [], stack, context, line, offset)
  end

  defp consume__932(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__933(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__932(rest, acc, stack, context, line, offset) do
    consume__931(rest, acc, stack, context, line, offset)
  end

  defp consume__933(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__928(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__934(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__932(rest, [], stack, context, line, offset)
  end

  defp consume__935(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__936(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__935(rest, acc, stack, context, line, offset) do
    consume__934(rest, acc, stack, context, line, offset)
  end

  defp consume__936(rest, acc, stack, context, line, offset) do
    consume__938(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__938(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__939(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__938(rest, acc, stack, context, line, offset) do
    consume__937(rest, acc, stack, context, line, offset)
  end

  defp consume__937(rest, acc, [_ | stack], context, line, offset) do
    consume__940(rest, acc, stack, context, line, offset)
  end

  defp consume__939(rest, acc, [1 | stack], context, line, offset) do
    consume__940(rest, acc, stack, context, line, offset)
  end

  defp consume__939(rest, acc, [count | stack], context, line, offset) do
    consume__938(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__940(rest, acc, stack, context, line, offset) do
    consume__944(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__942(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__941(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__943(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__942(rest, [], stack, context, line, offset)
  end

  defp consume__944(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__945(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__944(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__945(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__944(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__945(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__944(rest, acc, stack, context, line, offset) do
    consume__943(rest, acc, stack, context, line, offset)
  end

  defp consume__945(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__941(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__941(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__928(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__928(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__925(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__946(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__926(rest, [], stack, context, line, offset)
  end

  defp consume__947(<<"\\", "\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__948(
      rest,
      ["\n", "\\"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 2},
      comb__offset + 2
    )
  end

  defp consume__947(rest, acc, stack, context, line, offset) do
    consume__946(rest, acc, stack, context, line, offset)
  end

  defp consume__948(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__925(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__949(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__947(rest, [], stack, context, line, offset)
  end

  defp consume__950(rest, acc, stack, context, line, offset) do
    consume__951(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__951(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 and x0 !== 92 and x0 !== 10 do
    consume__952(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__951(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__949(rest, acc, stack, context, line, offset)
  end

  defp consume__952(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 and x0 !== 92 and x0 !== 10 do
    consume__954(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__952(rest, acc, stack, context, line, offset) do
    consume__953(rest, acc, stack, context, line, offset)
  end

  defp consume__954(rest, acc, stack, context, line, offset) do
    consume__952(rest, acc, stack, context, line, offset)
  end

  defp consume__953(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__955(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__955(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__925(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__923(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__956(rest, acc, stack, context, line, offset)
  end

  defp consume__925(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__924(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__956(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__957(rest, ["\""] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__956(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__957("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__956(rest, acc, stack, context, line, offset) do
    consume__920(rest, acc, stack, context, line, offset)
  end

  defp consume__957(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__882(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__882(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__958(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__958(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__959(
      rest,
      [
        string:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__959(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__960(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__879(rest, [], stack, context, line, offset)
  end

  defp consume__961(rest, acc, stack, context, line, offset) do
    consume__962(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__962(rest, acc, stack, context, line, offset) do
    consume__963(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__963(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__964(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__963(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__964(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__963(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__964(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__963(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__960(rest, acc, stack, context, line, offset)
  end

  defp consume__964(rest, acc, stack, context, line, offset) do
    consume__966(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__966(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__967(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__966(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__967(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__966(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__967(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__966(rest, acc, stack, context, line, offset) do
    consume__965(rest, acc, stack, context, line, offset)
  end

  defp consume__965(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__968(rest, acc, stack, context, line, offset)
  end

  defp consume__967(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__966(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__968(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__969(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__969(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__970(
      rest,
      [
        whitespace:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__970(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__7(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__971(
      rest,
      [StylesheetParser.Syntax.Tokenizer.at(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__971(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__3(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__972(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__4(rest, [], stack, context, line, offset)
  end

  defp consume__973(rest, acc, stack, context, line, offset) do
    consume__974(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__974(<<"/*", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__975(rest, acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__974(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__972(rest, acc, stack, context, line, offset)
  end

  defp consume__975(<<"*/", _::binary>> = rest, acc, stack, context, line, offset) do
    consume__976(rest, acc, stack, context, line, offset)
  end

  defp consume__975(rest, acc, stack, context, line, offset) do
    consume__977(rest, acc, stack, context, line, offset)
  end

  defp consume__977(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__978(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__977(rest, acc, stack, context, line, offset) do
    consume__976(rest, acc, stack, context, line, offset)
  end

  defp consume__978(rest, acc, stack, context, line, offset) do
    consume__975(rest, acc, stack, context, line, offset)
  end

  defp consume__976(<<"*/", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__979(rest, acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__976(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__979("", acc, stack, context, comb__line, comb__offset)
  end

  defp consume__976(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__972(rest, acc, stack, context, line, offset)
  end

  defp consume__979(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    consume__980(rest, [] ++ acc, stack, context, line, offset)
  end

  defp consume__980(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__3(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__1(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__981(rest, acc, stack, context, line, offset)
  end

  defp consume__3(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__2(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__981(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end
end
