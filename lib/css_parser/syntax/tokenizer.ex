# Generated from lib/css_parser/syntax/tokenizer.ex.exs, do not edit.
# Generated at 2026-11-20 20:46:41Z.

defmodule CssParser.Syntax.Tokenizer do
  @moduledoc """
  The [tokenizer](https://www.w3.org/TR/css-syntax-3/#tokenization) of CSS Syntax Level 3, over
  preprocessed input (`CssParser.tokenize/1` turns `\\r\\n`, `\\r` and `\\f` into `\\n` and NUL into
  U+FFFD).

  Each token's value is its source text: a string keeps its quotes, and escapes stay escaped.
  Comments are dropped, an unclosed one running to the end. A string with a newline in it is a
  `:bad_string`, and a `url(` with whitespace or a quote inside is a `:bad_url`.
  """

  # The template for `tokenizer.ex`, so NimbleParsec isn't needed at runtime. After changing it:
  #
  #     mix nimble_parsec.compile lib/css_parser/syntax/tokenizer.ex.exs

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
    consume__859(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
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
    consume__847(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
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

  defp consume__310(
         <<x0, x1, x2, "(", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 117 or x0 === 85) and (x1 === 114 or x1 === 82) and (x2 === 108 or x2 === 76) do
    consume__311(
      rest,
      ["(", <<x2::integer>>, <<x1::integer>>, <<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp consume__310(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__307(rest, acc, stack, context, line, offset)
  end

  defp consume__311(rest, acc, stack, context, line, offset) do
    consume__313(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__313(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__314(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__313(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__314(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__313(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__314(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__313(rest, acc, stack, context, line, offset) do
    consume__312(rest, acc, stack, context, line, offset)
  end

  defp consume__312(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__315(rest, acc, stack, context, line, offset)
  end

  defp consume__314(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__313(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__315(<<x0, _::binary>> = rest, _acc, stack, context, line, offset)
       when x0 === 34 or x0 === 39 do
    [_, acc | stack] = stack
    consume__307(rest, acc, stack, context, line, offset)
  end

  defp consume__315(rest, acc, stack, context, line, offset) do
    consume__316(rest, acc, stack, context, line, offset)
  end

  defp consume__316(rest, acc, stack, context, line, offset) do
    consume__318(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__318(rest, acc, stack, context, line, offset) do
    consume__330(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__320(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__321(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__320(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__317(rest, acc, stack, context, line, offset)
  end

  defp consume__321(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__319(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__322(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__320(rest, [], stack, context, line, offset)
  end

  defp consume__323(rest, acc, stack, context, line, offset) do
    consume__324(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__324(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 41 and x0 !== 92 do
    consume__325(
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

  defp consume__324(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__322(rest, acc, stack, context, line, offset)
  end

  defp consume__325(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 41 and x0 !== 92 do
    consume__327(
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

  defp consume__325(rest, acc, stack, context, line, offset) do
    consume__326(rest, acc, stack, context, line, offset)
  end

  defp consume__327(rest, acc, stack, context, line, offset) do
    consume__325(rest, acc, stack, context, line, offset)
  end

  defp consume__326(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__328(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__328(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__319(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__329(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__323(rest, [], stack, context, line, offset)
  end

  defp consume__330(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__331(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__330(rest, acc, stack, context, line, offset) do
    consume__329(rest, acc, stack, context, line, offset)
  end

  defp consume__331(rest, acc, stack, context, line, offset) do
    consume__339(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__333(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__334("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__333(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__329(rest, acc, stack, context, line, offset)
  end

  defp consume__334(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__332(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__335(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__333(rest, [], stack, context, line, offset)
  end

  defp consume__336(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__337(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__336(rest, acc, stack, context, line, offset) do
    consume__335(rest, acc, stack, context, line, offset)
  end

  defp consume__337(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__332(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__338(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__336(rest, [], stack, context, line, offset)
  end

  defp consume__339(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__340(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__339(rest, acc, stack, context, line, offset) do
    consume__338(rest, acc, stack, context, line, offset)
  end

  defp consume__340(rest, acc, stack, context, line, offset) do
    consume__342(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__342(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__343(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__342(rest, acc, stack, context, line, offset) do
    consume__341(rest, acc, stack, context, line, offset)
  end

  defp consume__341(rest, acc, [_ | stack], context, line, offset) do
    consume__344(rest, acc, stack, context, line, offset)
  end

  defp consume__343(rest, acc, [1 | stack], context, line, offset) do
    consume__344(rest, acc, stack, context, line, offset)
  end

  defp consume__343(rest, acc, [count | stack], context, line, offset) do
    consume__342(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__344(rest, acc, stack, context, line, offset) do
    consume__348(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__346(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__345(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__347(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__346(rest, [], stack, context, line, offset)
  end

  defp consume__348(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__349(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__348(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__349(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__348(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__349(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__348(rest, acc, stack, context, line, offset) do
    consume__347(rest, acc, stack, context, line, offset)
  end

  defp consume__349(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__345(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__345(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__332(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__332(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__319(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__317(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__350(rest, acc, stack, context, line, offset)
  end

  defp consume__319(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__318(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__350(<<")", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__351(rest, [")"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__350(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__351("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__350(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__307(rest, acc, stack, context, line, offset)
  end

  defp consume__351(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__352(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__352(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__353(
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

  defp consume__353(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__354(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__308(rest, [], stack, context, line, offset)
  end

  defp consume__355(rest, acc, stack, context, line, offset) do
    consume__356(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__356(rest, acc, stack, context, line, offset) do
    consume__357(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__357(
         <<x0, x1, x2, "(", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 117 or x0 === 85) and (x1 === 114 or x1 === 82) and (x2 === 108 or x2 === 76) do
    consume__358(
      rest,
      ["(", <<x2::integer>>, <<x1::integer>>, <<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp consume__357(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__354(rest, acc, stack, context, line, offset)
  end

  defp consume__358(rest, acc, stack, context, line, offset) do
    consume__360(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
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

  defp consume__359(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__362(rest, acc, stack, context, line, offset)
  end

  defp consume__361(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__360(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__362(rest, acc, stack, context, line, offset) do
    consume__364(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__364(rest, acc, stack, context, line, offset) do
    consume__387(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__366(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__367(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__366(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__363(rest, acc, stack, context, line, offset)
  end

  defp consume__367(rest, acc, stack, context, line, offset) do
    consume__375(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__369(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__370("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__369(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__363(rest, acc, stack, context, line, offset)
  end

  defp consume__370(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__368(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__371(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__369(rest, [], stack, context, line, offset)
  end

  defp consume__372(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__373(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__372(rest, acc, stack, context, line, offset) do
    consume__371(rest, acc, stack, context, line, offset)
  end

  defp consume__373(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__368(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__374(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__372(rest, [], stack, context, line, offset)
  end

  defp consume__375(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__376(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__375(rest, acc, stack, context, line, offset) do
    consume__374(rest, acc, stack, context, line, offset)
  end

  defp consume__376(rest, acc, stack, context, line, offset) do
    consume__378(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__378(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__379(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__378(rest, acc, stack, context, line, offset) do
    consume__377(rest, acc, stack, context, line, offset)
  end

  defp consume__377(rest, acc, [_ | stack], context, line, offset) do
    consume__380(rest, acc, stack, context, line, offset)
  end

  defp consume__379(rest, acc, [1 | stack], context, line, offset) do
    consume__380(rest, acc, stack, context, line, offset)
  end

  defp consume__379(rest, acc, [count | stack], context, line, offset) do
    consume__378(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__380(rest, acc, stack, context, line, offset) do
    consume__384(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__382(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__381(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__383(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__382(rest, [], stack, context, line, offset)
  end

  defp consume__384(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__385(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__384(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__385(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__384(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__385(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__384(rest, acc, stack, context, line, offset) do
    consume__383(rest, acc, stack, context, line, offset)
  end

  defp consume__385(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__381(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__381(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__368(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__368(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__365(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__386(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__366(rest, [], stack, context, line, offset)
  end

  defp consume__387(rest, acc, stack, context, line, offset) do
    consume__388(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__388(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 and x0 !== 39 and x0 !== 40 and x0 !== 41 and x0 !== 92 and x0 !== 32 and
              x0 !== 9 and
              x0 !== 10 and (x0 < 0 or x0 > 8) and x0 !== 11 and (x0 < 14 or x0 > 31) and
              x0 !== 127 do
    consume__389(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__388(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__386(rest, acc, stack, context, line, offset)
  end

  defp consume__389(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 and x0 !== 39 and x0 !== 40 and x0 !== 41 and x0 !== 92 and x0 !== 32 and
              x0 !== 9 and
              x0 !== 10 and (x0 < 0 or x0 > 8) and x0 !== 11 and (x0 < 14 or x0 > 31) and
              x0 !== 127 do
    consume__391(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__389(rest, acc, stack, context, line, offset) do
    consume__390(rest, acc, stack, context, line, offset)
  end

  defp consume__391(rest, acc, stack, context, line, offset) do
    consume__389(rest, acc, stack, context, line, offset)
  end

  defp consume__390(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__392(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__392(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__365(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__363(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__393(rest, acc, stack, context, line, offset)
  end

  defp consume__365(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__364(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__393(rest, acc, stack, context, line, offset) do
    consume__395(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__395(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__396(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__395(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__396(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__395(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__396(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__395(rest, acc, stack, context, line, offset) do
    consume__394(rest, acc, stack, context, line, offset)
  end

  defp consume__394(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__397(rest, acc, stack, context, line, offset)
  end

  defp consume__396(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__395(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__397(<<")", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__398(rest, [")"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__397(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__398("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__397(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__354(rest, acc, stack, context, line, offset)
  end

  defp consume__398(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__399(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__399(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__400(
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

  defp consume__400(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__401(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__355(rest, [], stack, context, line, offset)
  end

  defp consume__402(<<"-->", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__403(rest, [cdc: "-->"] ++ acc, stack, context, comb__line, comb__offset + 3)
  end

  defp consume__402(rest, acc, stack, context, line, offset) do
    consume__401(rest, acc, stack, context, line, offset)
  end

  defp consume__403(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__404(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__402(rest, [], stack, context, line, offset)
  end

  defp consume__405(rest, acc, stack, context, line, offset) do
    consume__406(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__406(rest, acc, stack, context, line, offset) do
    consume__407(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__407(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 43 or x0 === 45 do
    consume__408(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__407(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__408(rest, [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__408(rest, acc, stack, context, line, offset) do
    consume__425(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__410(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__411(rest, ["."] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__410(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__404(rest, acc, stack, context, line, offset)
  end

  defp consume__411(rest, acc, stack, context, line, offset) do
    consume__412(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__412(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__413(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__412(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    consume__404(rest, acc, stack, context, line, offset)
  end

  defp consume__413(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__415(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__413(rest, acc, stack, context, line, offset) do
    consume__414(rest, acc, stack, context, line, offset)
  end

  defp consume__415(rest, acc, stack, context, line, offset) do
    consume__413(rest, acc, stack, context, line, offset)
  end

  defp consume__414(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__416(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__416(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__409(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__417(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__410(rest, [], stack, context, line, offset)
  end

  defp consume__418(rest, acc, stack, context, line, offset) do
    consume__419(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__419(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__420(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__419(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__417(rest, acc, stack, context, line, offset)
  end

  defp consume__420(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__422(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__420(rest, acc, stack, context, line, offset) do
    consume__421(rest, acc, stack, context, line, offset)
  end

  defp consume__422(rest, acc, stack, context, line, offset) do
    consume__420(rest, acc, stack, context, line, offset)
  end

  defp consume__421(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__423(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__423(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__409(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__424(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__418(rest, [], stack, context, line, offset)
  end

  defp consume__425(rest, acc, stack, context, line, offset) do
    consume__426(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__426(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__427(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__426(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__424(rest, acc, stack, context, line, offset)
  end

  defp consume__427(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__429(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__427(rest, acc, stack, context, line, offset) do
    consume__428(rest, acc, stack, context, line, offset)
  end

  defp consume__429(rest, acc, stack, context, line, offset) do
    consume__427(rest, acc, stack, context, line, offset)
  end

  defp consume__428(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__430(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__430(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__431(rest, ["."] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__430(rest, acc, stack, context, line, offset) do
    consume__424(rest, acc, stack, context, line, offset)
  end

  defp consume__431(rest, acc, stack, context, line, offset) do
    consume__432(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__432(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__433(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__432(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__424(rest, acc, stack, context, line, offset)
  end

  defp consume__433(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__435(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__433(rest, acc, stack, context, line, offset) do
    consume__434(rest, acc, stack, context, line, offset)
  end

  defp consume__435(rest, acc, stack, context, line, offset) do
    consume__433(rest, acc, stack, context, line, offset)
  end

  defp consume__434(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__436(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__436(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__409(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__409(rest, acc, stack, context, line, offset) do
    consume__440(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__438(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__437(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__439(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__438(rest, [], stack, context, line, offset)
  end

  defp consume__440(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 101 or x0 === 69 do
    consume__441(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__440(rest, acc, stack, context, line, offset) do
    consume__439(rest, acc, stack, context, line, offset)
  end

  defp consume__441(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 43 or x0 === 45 do
    consume__442(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__441(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__442(rest, [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__442(rest, acc, stack, context, line, offset) do
    consume__443(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__443(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__444(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__443(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__439(rest, acc, stack, context, line, offset)
  end

  defp consume__444(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__446(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__444(rest, acc, stack, context, line, offset) do
    consume__445(rest, acc, stack, context, line, offset)
  end

  defp consume__446(rest, acc, stack, context, line, offset) do
    consume__444(rest, acc, stack, context, line, offset)
  end

  defp consume__445(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__447(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__447(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__437(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__437(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__448(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__448(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__449(
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

  defp consume__449(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__450(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__405(rest, [], stack, context, line, offset)
  end

  defp consume__451(rest, acc, stack, context, line, offset) do
    consume__452(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__452(rest, acc, stack, context, line, offset) do
    consume__453(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__453(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 43 or x0 === 45 do
    consume__454(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__453(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__454(rest, [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__454(rest, acc, stack, context, line, offset) do
    consume__471(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__456(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__457(rest, ["."] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__456(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__450(rest, acc, stack, context, line, offset)
  end

  defp consume__457(rest, acc, stack, context, line, offset) do
    consume__458(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__458(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__459(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__458(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    consume__450(rest, acc, stack, context, line, offset)
  end

  defp consume__459(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__461(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__459(rest, acc, stack, context, line, offset) do
    consume__460(rest, acc, stack, context, line, offset)
  end

  defp consume__461(rest, acc, stack, context, line, offset) do
    consume__459(rest, acc, stack, context, line, offset)
  end

  defp consume__460(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__462(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__462(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__455(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__463(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__456(rest, [], stack, context, line, offset)
  end

  defp consume__464(rest, acc, stack, context, line, offset) do
    consume__465(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__465(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__466(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__465(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__463(rest, acc, stack, context, line, offset)
  end

  defp consume__466(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__468(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__466(rest, acc, stack, context, line, offset) do
    consume__467(rest, acc, stack, context, line, offset)
  end

  defp consume__468(rest, acc, stack, context, line, offset) do
    consume__466(rest, acc, stack, context, line, offset)
  end

  defp consume__467(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__469(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__469(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__455(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__470(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__464(rest, [], stack, context, line, offset)
  end

  defp consume__471(rest, acc, stack, context, line, offset) do
    consume__472(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__472(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__473(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__472(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__470(rest, acc, stack, context, line, offset)
  end

  defp consume__473(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__475(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__473(rest, acc, stack, context, line, offset) do
    consume__474(rest, acc, stack, context, line, offset)
  end

  defp consume__475(rest, acc, stack, context, line, offset) do
    consume__473(rest, acc, stack, context, line, offset)
  end

  defp consume__474(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__476(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__476(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__477(rest, ["."] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__476(rest, acc, stack, context, line, offset) do
    consume__470(rest, acc, stack, context, line, offset)
  end

  defp consume__477(rest, acc, stack, context, line, offset) do
    consume__478(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__478(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__479(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__478(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__470(rest, acc, stack, context, line, offset)
  end

  defp consume__479(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__481(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__479(rest, acc, stack, context, line, offset) do
    consume__480(rest, acc, stack, context, line, offset)
  end

  defp consume__481(rest, acc, stack, context, line, offset) do
    consume__479(rest, acc, stack, context, line, offset)
  end

  defp consume__480(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__482(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__482(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__455(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__455(rest, acc, stack, context, line, offset) do
    consume__486(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__484(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__483(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__485(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__484(rest, [], stack, context, line, offset)
  end

  defp consume__486(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 101 or x0 === 69 do
    consume__487(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__486(rest, acc, stack, context, line, offset) do
    consume__485(rest, acc, stack, context, line, offset)
  end

  defp consume__487(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 43 or x0 === 45 do
    consume__488(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__487(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__488(rest, [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__488(rest, acc, stack, context, line, offset) do
    consume__489(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__489(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__490(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__489(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__485(rest, acc, stack, context, line, offset)
  end

  defp consume__490(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__492(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__490(rest, acc, stack, context, line, offset) do
    consume__491(rest, acc, stack, context, line, offset)
  end

  defp consume__492(rest, acc, stack, context, line, offset) do
    consume__490(rest, acc, stack, context, line, offset)
  end

  defp consume__491(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__493(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__493(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__483(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__483(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__494(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__494(<<"%", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__495(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__494(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__450(rest, acc, stack, context, line, offset)
  end

  defp consume__495(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__496(
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

  defp consume__496(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__497(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__451(rest, [], stack, context, line, offset)
  end

  defp consume__498(rest, acc, stack, context, line, offset) do
    consume__499(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__499(rest, acc, stack, context, line, offset) do
    consume__500(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__500(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 43 or x0 === 45 do
    consume__501(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__500(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__501(rest, [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__501(rest, acc, stack, context, line, offset) do
    consume__518(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__503(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__504(rest, ["."] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__503(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__497(rest, acc, stack, context, line, offset)
  end

  defp consume__504(rest, acc, stack, context, line, offset) do
    consume__505(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__505(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__506(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__505(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    consume__497(rest, acc, stack, context, line, offset)
  end

  defp consume__506(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__508(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__506(rest, acc, stack, context, line, offset) do
    consume__507(rest, acc, stack, context, line, offset)
  end

  defp consume__508(rest, acc, stack, context, line, offset) do
    consume__506(rest, acc, stack, context, line, offset)
  end

  defp consume__507(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__509(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__509(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__502(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__510(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__503(rest, [], stack, context, line, offset)
  end

  defp consume__511(rest, acc, stack, context, line, offset) do
    consume__512(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__512(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__513(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__512(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__510(rest, acc, stack, context, line, offset)
  end

  defp consume__513(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__515(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__513(rest, acc, stack, context, line, offset) do
    consume__514(rest, acc, stack, context, line, offset)
  end

  defp consume__515(rest, acc, stack, context, line, offset) do
    consume__513(rest, acc, stack, context, line, offset)
  end

  defp consume__514(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__516(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__516(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__502(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__517(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__511(rest, [], stack, context, line, offset)
  end

  defp consume__518(rest, acc, stack, context, line, offset) do
    consume__519(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__519(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__520(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__519(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__517(rest, acc, stack, context, line, offset)
  end

  defp consume__520(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__522(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__520(rest, acc, stack, context, line, offset) do
    consume__521(rest, acc, stack, context, line, offset)
  end

  defp consume__522(rest, acc, stack, context, line, offset) do
    consume__520(rest, acc, stack, context, line, offset)
  end

  defp consume__521(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__523(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__523(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__524(rest, ["."] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__523(rest, acc, stack, context, line, offset) do
    consume__517(rest, acc, stack, context, line, offset)
  end

  defp consume__524(rest, acc, stack, context, line, offset) do
    consume__525(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__525(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__526(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__525(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__517(rest, acc, stack, context, line, offset)
  end

  defp consume__526(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__528(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__526(rest, acc, stack, context, line, offset) do
    consume__527(rest, acc, stack, context, line, offset)
  end

  defp consume__528(rest, acc, stack, context, line, offset) do
    consume__526(rest, acc, stack, context, line, offset)
  end

  defp consume__527(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__529(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__529(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__502(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__502(rest, acc, stack, context, line, offset) do
    consume__533(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__531(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__530(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__532(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__531(rest, [], stack, context, line, offset)
  end

  defp consume__533(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 101 or x0 === 69 do
    consume__534(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__533(rest, acc, stack, context, line, offset) do
    consume__532(rest, acc, stack, context, line, offset)
  end

  defp consume__534(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 43 or x0 === 45 do
    consume__535(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__534(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__535(rest, [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__535(rest, acc, stack, context, line, offset) do
    consume__536(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__536(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__537(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__536(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__532(rest, acc, stack, context, line, offset)
  end

  defp consume__537(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 48 and x0 <= 57 do
    consume__539(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__537(rest, acc, stack, context, line, offset) do
    consume__538(rest, acc, stack, context, line, offset)
  end

  defp consume__539(rest, acc, stack, context, line, offset) do
    consume__537(rest, acc, stack, context, line, offset)
  end

  defp consume__538(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__540(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__540(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__530(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__530(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__541(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__541(rest, acc, stack, context, line, offset) do
    consume__542(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__542(rest, acc, stack, context, line, offset) do
    consume__568(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__544(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__545(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__544(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__497(rest, acc, stack, context, line, offset)
  end

  defp consume__545(rest, acc, stack, context, line, offset) do
    consume__553(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__547(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__548("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__547(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, _, acc | stack] = stack
    consume__497(rest, acc, stack, context, line, offset)
  end

  defp consume__548(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__546(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__549(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__547(rest, [], stack, context, line, offset)
  end

  defp consume__550(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__551(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__550(rest, acc, stack, context, line, offset) do
    consume__549(rest, acc, stack, context, line, offset)
  end

  defp consume__551(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__546(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__552(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__550(rest, [], stack, context, line, offset)
  end

  defp consume__553(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__554(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__553(rest, acc, stack, context, line, offset) do
    consume__552(rest, acc, stack, context, line, offset)
  end

  defp consume__554(rest, acc, stack, context, line, offset) do
    consume__556(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__556(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__557(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__556(rest, acc, stack, context, line, offset) do
    consume__555(rest, acc, stack, context, line, offset)
  end

  defp consume__555(rest, acc, [_ | stack], context, line, offset) do
    consume__558(rest, acc, stack, context, line, offset)
  end

  defp consume__557(rest, acc, [1 | stack], context, line, offset) do
    consume__558(rest, acc, stack, context, line, offset)
  end

  defp consume__557(rest, acc, [count | stack], context, line, offset) do
    consume__556(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__558(rest, acc, stack, context, line, offset) do
    consume__562(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__560(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__559(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__561(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__560(rest, [], stack, context, line, offset)
  end

  defp consume__562(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__563(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__562(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__563(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__562(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__563(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__562(rest, acc, stack, context, line, offset) do
    consume__561(rest, acc, stack, context, line, offset)
  end

  defp consume__563(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__559(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__559(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__546(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__546(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__543(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__564(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__544(rest, [], stack, context, line, offset)
  end

  defp consume__565(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or x0 === 95 do
    consume__566(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__565(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__566(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__565(rest, acc, stack, context, line, offset) do
    consume__564(rest, acc, stack, context, line, offset)
  end

  defp consume__566(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__543(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__567(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__565(rest, [], stack, context, line, offset)
  end

  defp consume__568(<<"-", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__569(rest, ["-"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__568(rest, acc, stack, context, line, offset) do
    consume__567(rest, acc, stack, context, line, offset)
  end

  defp consume__569(rest, acc, stack, context, line, offset) do
    consume__595(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__571(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__572(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__571(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__567(rest, acc, stack, context, line, offset)
  end

  defp consume__572(rest, acc, stack, context, line, offset) do
    consume__580(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__574(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__575("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__574(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__567(rest, acc, stack, context, line, offset)
  end

  defp consume__575(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__573(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__576(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__574(rest, [], stack, context, line, offset)
  end

  defp consume__577(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__578(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__577(rest, acc, stack, context, line, offset) do
    consume__576(rest, acc, stack, context, line, offset)
  end

  defp consume__578(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__573(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__579(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__577(rest, [], stack, context, line, offset)
  end

  defp consume__580(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__581(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__580(rest, acc, stack, context, line, offset) do
    consume__579(rest, acc, stack, context, line, offset)
  end

  defp consume__581(rest, acc, stack, context, line, offset) do
    consume__583(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__583(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__584(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__583(rest, acc, stack, context, line, offset) do
    consume__582(rest, acc, stack, context, line, offset)
  end

  defp consume__582(rest, acc, [_ | stack], context, line, offset) do
    consume__585(rest, acc, stack, context, line, offset)
  end

  defp consume__584(rest, acc, [1 | stack], context, line, offset) do
    consume__585(rest, acc, stack, context, line, offset)
  end

  defp consume__584(rest, acc, [count | stack], context, line, offset) do
    consume__583(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__585(rest, acc, stack, context, line, offset) do
    consume__589(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__587(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__586(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__588(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__587(rest, [], stack, context, line, offset)
  end

  defp consume__589(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__590(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__589(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__590(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__589(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__590(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__589(rest, acc, stack, context, line, offset) do
    consume__588(rest, acc, stack, context, line, offset)
  end

  defp consume__590(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__586(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__586(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__573(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__573(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__570(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__591(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__571(rest, [], stack, context, line, offset)
  end

  defp consume__592(<<"-", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__593(rest, ["-"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__592(rest, acc, stack, context, line, offset) do
    consume__591(rest, acc, stack, context, line, offset)
  end

  defp consume__593(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__570(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__594(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__592(rest, [], stack, context, line, offset)
  end

  defp consume__595(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or x0 === 95 do
    consume__596(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__595(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__596(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__595(rest, acc, stack, context, line, offset) do
    consume__594(rest, acc, stack, context, line, offset)
  end

  defp consume__596(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__570(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__570(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__543(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__543(rest, acc, stack, context, line, offset) do
    consume__598(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__598(rest, acc, stack, context, line, offset) do
    consume__621(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__600(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__601(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__600(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__597(rest, acc, stack, context, line, offset)
  end

  defp consume__601(rest, acc, stack, context, line, offset) do
    consume__609(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__603(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__604("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__603(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__597(rest, acc, stack, context, line, offset)
  end

  defp consume__604(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__602(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__605(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__603(rest, [], stack, context, line, offset)
  end

  defp consume__606(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__607(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__606(rest, acc, stack, context, line, offset) do
    consume__605(rest, acc, stack, context, line, offset)
  end

  defp consume__607(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__602(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__608(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__606(rest, [], stack, context, line, offset)
  end

  defp consume__609(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__610(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__609(rest, acc, stack, context, line, offset) do
    consume__608(rest, acc, stack, context, line, offset)
  end

  defp consume__610(rest, acc, stack, context, line, offset) do
    consume__612(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__612(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__613(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__612(rest, acc, stack, context, line, offset) do
    consume__611(rest, acc, stack, context, line, offset)
  end

  defp consume__611(rest, acc, [_ | stack], context, line, offset) do
    consume__614(rest, acc, stack, context, line, offset)
  end

  defp consume__613(rest, acc, [1 | stack], context, line, offset) do
    consume__614(rest, acc, stack, context, line, offset)
  end

  defp consume__613(rest, acc, [count | stack], context, line, offset) do
    consume__612(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__614(rest, acc, stack, context, line, offset) do
    consume__618(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__616(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__615(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__617(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__616(rest, [], stack, context, line, offset)
  end

  defp consume__618(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__619(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__618(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__619(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__618(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__619(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__618(rest, acc, stack, context, line, offset) do
    consume__617(rest, acc, stack, context, line, offset)
  end

  defp consume__619(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__615(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__615(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__602(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__602(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__599(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__620(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__600(rest, [], stack, context, line, offset)
  end

  defp consume__621(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    consume__622(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__621(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__622(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__621(rest, acc, stack, context, line, offset) do
    consume__620(rest, acc, stack, context, line, offset)
  end

  defp consume__622(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__599(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__597(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__623(rest, acc, stack, context, line, offset)
  end

  defp consume__599(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__598(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__623(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__624(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__624(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    consume__625(rest, [dimension: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp consume__625(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__626(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__498(rest, [], stack, context, line, offset)
  end

  defp consume__627(rest, acc, stack, context, line, offset) do
    consume__628(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__628(rest, acc, stack, context, line, offset) do
    consume__629(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__629(<<"#", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__630(rest, ["#"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__629(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__626(rest, acc, stack, context, line, offset)
  end

  defp consume__630(rest, acc, stack, context, line, offset) do
    consume__653(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__632(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__633(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__632(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__626(rest, acc, stack, context, line, offset)
  end

  defp consume__633(rest, acc, stack, context, line, offset) do
    consume__641(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__635(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__636("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__635(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, _, acc | stack] = stack
    consume__626(rest, acc, stack, context, line, offset)
  end

  defp consume__636(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__634(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__637(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__635(rest, [], stack, context, line, offset)
  end

  defp consume__638(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__639(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__638(rest, acc, stack, context, line, offset) do
    consume__637(rest, acc, stack, context, line, offset)
  end

  defp consume__639(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__634(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__640(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__638(rest, [], stack, context, line, offset)
  end

  defp consume__641(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__642(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__641(rest, acc, stack, context, line, offset) do
    consume__640(rest, acc, stack, context, line, offset)
  end

  defp consume__642(rest, acc, stack, context, line, offset) do
    consume__644(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__644(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__645(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__644(rest, acc, stack, context, line, offset) do
    consume__643(rest, acc, stack, context, line, offset)
  end

  defp consume__643(rest, acc, [_ | stack], context, line, offset) do
    consume__646(rest, acc, stack, context, line, offset)
  end

  defp consume__645(rest, acc, [1 | stack], context, line, offset) do
    consume__646(rest, acc, stack, context, line, offset)
  end

  defp consume__645(rest, acc, [count | stack], context, line, offset) do
    consume__644(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__646(rest, acc, stack, context, line, offset) do
    consume__650(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__648(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__647(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__649(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__648(rest, [], stack, context, line, offset)
  end

  defp consume__650(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__651(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__650(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__651(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__650(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__651(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__650(rest, acc, stack, context, line, offset) do
    consume__649(rest, acc, stack, context, line, offset)
  end

  defp consume__651(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__647(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__647(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__634(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__634(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__631(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__652(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__632(rest, [], stack, context, line, offset)
  end

  defp consume__653(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    consume__654(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__653(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 >= 128 and x0 <= 1_114_111 do
    consume__654(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__653(rest, acc, stack, context, line, offset) do
    consume__652(rest, acc, stack, context, line, offset)
  end

  defp consume__654(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__631(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__631(rest, acc, stack, context, line, offset) do
    consume__656(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__656(rest, acc, stack, context, line, offset) do
    consume__679(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__658(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__659(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__658(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__655(rest, acc, stack, context, line, offset)
  end

  defp consume__659(rest, acc, stack, context, line, offset) do
    consume__667(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__661(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__662("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__661(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__655(rest, acc, stack, context, line, offset)
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
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
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

  defp consume__655(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__681(rest, acc, stack, context, line, offset)
  end

  defp consume__657(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__656(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__681(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__682(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__682(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__683(
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

  defp consume__683(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__684(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__627(rest, [], stack, context, line, offset)
  end

  defp consume__685(rest, acc, stack, context, line, offset) do
    consume__686(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__686(rest, acc, stack, context, line, offset) do
    consume__687(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__687(rest, acc, stack, context, line, offset) do
    consume__726(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__689(<<"'", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__690(rest, ["'"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__689(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__684(rest, acc, stack, context, line, offset)
  end

  defp consume__690(rest, acc, stack, context, line, offset) do
    consume__692(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__692(rest, acc, stack, context, line, offset) do
    consume__718(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__694(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__695(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__694(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__691(rest, acc, stack, context, line, offset)
  end

  defp consume__695(rest, acc, stack, context, line, offset) do
    consume__703(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__697(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__698("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__697(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__691(rest, acc, stack, context, line, offset)
  end

  defp consume__698(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__696(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__699(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__697(rest, [], stack, context, line, offset)
  end

  defp consume__700(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__701(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__700(rest, acc, stack, context, line, offset) do
    consume__699(rest, acc, stack, context, line, offset)
  end

  defp consume__701(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__696(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__702(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__700(rest, [], stack, context, line, offset)
  end

  defp consume__703(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__704(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__703(rest, acc, stack, context, line, offset) do
    consume__702(rest, acc, stack, context, line, offset)
  end

  defp consume__704(rest, acc, stack, context, line, offset) do
    consume__706(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__706(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__707(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__706(rest, acc, stack, context, line, offset) do
    consume__705(rest, acc, stack, context, line, offset)
  end

  defp consume__705(rest, acc, [_ | stack], context, line, offset) do
    consume__708(rest, acc, stack, context, line, offset)
  end

  defp consume__707(rest, acc, [1 | stack], context, line, offset) do
    consume__708(rest, acc, stack, context, line, offset)
  end

  defp consume__707(rest, acc, [count | stack], context, line, offset) do
    consume__706(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__708(rest, acc, stack, context, line, offset) do
    consume__712(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__710(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__709(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__711(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__710(rest, [], stack, context, line, offset)
  end

  defp consume__712(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__713(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__712(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__713(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__712(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__713(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__712(rest, acc, stack, context, line, offset) do
    consume__711(rest, acc, stack, context, line, offset)
  end

  defp consume__713(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__709(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__709(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__696(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__696(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__693(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__714(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__694(rest, [], stack, context, line, offset)
  end

  defp consume__715(<<"\\", "\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__716(
      rest,
      ["\n", "\\"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 2},
      comb__offset + 2
    )
  end

  defp consume__715(rest, acc, stack, context, line, offset) do
    consume__714(rest, acc, stack, context, line, offset)
  end

  defp consume__716(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__693(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__717(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__715(rest, [], stack, context, line, offset)
  end

  defp consume__718(rest, acc, stack, context, line, offset) do
    consume__719(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__719(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 39 and x0 !== 92 and x0 !== 10 do
    consume__720(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__719(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__717(rest, acc, stack, context, line, offset)
  end

  defp consume__720(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 39 and x0 !== 92 and x0 !== 10 do
    consume__722(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__720(rest, acc, stack, context, line, offset) do
    consume__721(rest, acc, stack, context, line, offset)
  end

  defp consume__722(rest, acc, stack, context, line, offset) do
    consume__720(rest, acc, stack, context, line, offset)
  end

  defp consume__721(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__723(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__723(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__693(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__691(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__724(rest, acc, stack, context, line, offset)
  end

  defp consume__693(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__692(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__724(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__688(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__725(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__689(rest, [], stack, context, line, offset)
  end

  defp consume__726(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__727(rest, ["\""] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__726(rest, acc, stack, context, line, offset) do
    consume__725(rest, acc, stack, context, line, offset)
  end

  defp consume__727(rest, acc, stack, context, line, offset) do
    consume__729(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__729(rest, acc, stack, context, line, offset) do
    consume__755(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__731(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__732(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__731(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__728(rest, acc, stack, context, line, offset)
  end

  defp consume__732(rest, acc, stack, context, line, offset) do
    consume__740(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__734(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__735("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__734(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__728(rest, acc, stack, context, line, offset)
  end

  defp consume__735(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__733(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__736(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__734(rest, [], stack, context, line, offset)
  end

  defp consume__737(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__738(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__737(rest, acc, stack, context, line, offset) do
    consume__736(rest, acc, stack, context, line, offset)
  end

  defp consume__738(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__733(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__739(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__737(rest, [], stack, context, line, offset)
  end

  defp consume__740(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__741(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__740(rest, acc, stack, context, line, offset) do
    consume__739(rest, acc, stack, context, line, offset)
  end

  defp consume__741(rest, acc, stack, context, line, offset) do
    consume__743(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__743(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__744(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__743(rest, acc, stack, context, line, offset) do
    consume__742(rest, acc, stack, context, line, offset)
  end

  defp consume__742(rest, acc, [_ | stack], context, line, offset) do
    consume__745(rest, acc, stack, context, line, offset)
  end

  defp consume__744(rest, acc, [1 | stack], context, line, offset) do
    consume__745(rest, acc, stack, context, line, offset)
  end

  defp consume__744(rest, acc, [count | stack], context, line, offset) do
    consume__743(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__745(rest, acc, stack, context, line, offset) do
    consume__749(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__747(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__746(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__748(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__747(rest, [], stack, context, line, offset)
  end

  defp consume__749(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__750(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__749(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__750(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__749(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__750(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__749(rest, acc, stack, context, line, offset) do
    consume__748(rest, acc, stack, context, line, offset)
  end

  defp consume__750(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__746(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__746(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__733(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__733(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__730(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__751(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__731(rest, [], stack, context, line, offset)
  end

  defp consume__752(<<"\\", "\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__753(
      rest,
      ["\n", "\\"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 2},
      comb__offset + 2
    )
  end

  defp consume__752(rest, acc, stack, context, line, offset) do
    consume__751(rest, acc, stack, context, line, offset)
  end

  defp consume__753(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__730(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__754(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__752(rest, [], stack, context, line, offset)
  end

  defp consume__755(rest, acc, stack, context, line, offset) do
    consume__756(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__756(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 and x0 !== 92 and x0 !== 10 do
    consume__757(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__756(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__754(rest, acc, stack, context, line, offset)
  end

  defp consume__757(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 and x0 !== 92 and x0 !== 10 do
    consume__759(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__757(rest, acc, stack, context, line, offset) do
    consume__758(rest, acc, stack, context, line, offset)
  end

  defp consume__759(rest, acc, stack, context, line, offset) do
    consume__757(rest, acc, stack, context, line, offset)
  end

  defp consume__758(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__760(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__760(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__730(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__728(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__761(rest, acc, stack, context, line, offset)
  end

  defp consume__730(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__729(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__761(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__688(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__688(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__762(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__762(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__763(
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

  defp consume__763(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__764(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__685(rest, [], stack, context, line, offset)
  end

  defp consume__765(rest, acc, stack, context, line, offset) do
    consume__766(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__766(rest, acc, stack, context, line, offset) do
    consume__767(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__767(rest, acc, stack, context, line, offset) do
    consume__807(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__769(<<"'", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__770(rest, ["'"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__769(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__764(rest, acc, stack, context, line, offset)
  end

  defp consume__770(rest, acc, stack, context, line, offset) do
    consume__772(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__772(rest, acc, stack, context, line, offset) do
    consume__798(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__774(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__775(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__774(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__771(rest, acc, stack, context, line, offset)
  end

  defp consume__775(rest, acc, stack, context, line, offset) do
    consume__783(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__777(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__778("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__777(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__771(rest, acc, stack, context, line, offset)
  end

  defp consume__778(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__776(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__779(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__777(rest, [], stack, context, line, offset)
  end

  defp consume__780(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__781(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__780(rest, acc, stack, context, line, offset) do
    consume__779(rest, acc, stack, context, line, offset)
  end

  defp consume__781(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__776(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__782(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__780(rest, [], stack, context, line, offset)
  end

  defp consume__783(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__784(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__783(rest, acc, stack, context, line, offset) do
    consume__782(rest, acc, stack, context, line, offset)
  end

  defp consume__784(rest, acc, stack, context, line, offset) do
    consume__786(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__786(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__787(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__786(rest, acc, stack, context, line, offset) do
    consume__785(rest, acc, stack, context, line, offset)
  end

  defp consume__785(rest, acc, [_ | stack], context, line, offset) do
    consume__788(rest, acc, stack, context, line, offset)
  end

  defp consume__787(rest, acc, [1 | stack], context, line, offset) do
    consume__788(rest, acc, stack, context, line, offset)
  end

  defp consume__787(rest, acc, [count | stack], context, line, offset) do
    consume__786(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__788(rest, acc, stack, context, line, offset) do
    consume__792(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__790(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__789(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__791(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__790(rest, [], stack, context, line, offset)
  end

  defp consume__792(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__793(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__792(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__793(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__792(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__793(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__792(rest, acc, stack, context, line, offset) do
    consume__791(rest, acc, stack, context, line, offset)
  end

  defp consume__793(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__789(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__789(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__776(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__776(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__773(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__794(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__774(rest, [], stack, context, line, offset)
  end

  defp consume__795(<<"\\", "\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__796(
      rest,
      ["\n", "\\"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 2},
      comb__offset + 2
    )
  end

  defp consume__795(rest, acc, stack, context, line, offset) do
    consume__794(rest, acc, stack, context, line, offset)
  end

  defp consume__796(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__773(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__797(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__795(rest, [], stack, context, line, offset)
  end

  defp consume__798(rest, acc, stack, context, line, offset) do
    consume__799(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__799(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 39 and x0 !== 92 and x0 !== 10 do
    consume__800(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__799(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__797(rest, acc, stack, context, line, offset)
  end

  defp consume__800(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 39 and x0 !== 92 and x0 !== 10 do
    consume__802(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__800(rest, acc, stack, context, line, offset) do
    consume__801(rest, acc, stack, context, line, offset)
  end

  defp consume__802(rest, acc, stack, context, line, offset) do
    consume__800(rest, acc, stack, context, line, offset)
  end

  defp consume__801(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__803(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__803(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__773(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__771(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__804(rest, acc, stack, context, line, offset)
  end

  defp consume__773(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__772(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__804(<<"'", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__805(rest, ["'"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__804(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__805("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__804(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__764(rest, acc, stack, context, line, offset)
  end

  defp consume__805(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__768(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__806(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__769(rest, [], stack, context, line, offset)
  end

  defp consume__807(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__808(rest, ["\""] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__807(rest, acc, stack, context, line, offset) do
    consume__806(rest, acc, stack, context, line, offset)
  end

  defp consume__808(rest, acc, stack, context, line, offset) do
    consume__810(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__810(rest, acc, stack, context, line, offset) do
    consume__836(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__812(<<"\\", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__813(rest, ["\\"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__812(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__809(rest, acc, stack, context, line, offset)
  end

  defp consume__813(rest, acc, stack, context, line, offset) do
    consume__821(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__815(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__816("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__815(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    consume__809(rest, acc, stack, context, line, offset)
  end

  defp consume__816(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__814(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__817(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__815(rest, [], stack, context, line, offset)
  end

  defp consume__818(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 10 do
    consume__819(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__818(rest, acc, stack, context, line, offset) do
    consume__817(rest, acc, stack, context, line, offset)
  end

  defp consume__819(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__814(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__820(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__818(rest, [], stack, context, line, offset)
  end

  defp consume__821(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__822(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__821(rest, acc, stack, context, line, offset) do
    consume__820(rest, acc, stack, context, line, offset)
  end

  defp consume__822(rest, acc, stack, context, line, offset) do
    consume__824(rest, acc, [5 | stack], context, line, offset)
  end

  defp consume__824(<<x0, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 102) or (x0 >= 65 and x0 <= 70) do
    consume__825(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__824(rest, acc, stack, context, line, offset) do
    consume__823(rest, acc, stack, context, line, offset)
  end

  defp consume__823(rest, acc, [_ | stack], context, line, offset) do
    consume__826(rest, acc, stack, context, line, offset)
  end

  defp consume__825(rest, acc, [1 | stack], context, line, offset) do
    consume__826(rest, acc, stack, context, line, offset)
  end

  defp consume__825(rest, acc, [count | stack], context, line, offset) do
    consume__824(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp consume__826(rest, acc, stack, context, line, offset) do
    consume__830(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp consume__828(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__827(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__829(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__828(rest, [], stack, context, line, offset)
  end

  defp consume__830(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__831(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__830(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__831(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__830(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__831(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__830(rest, acc, stack, context, line, offset) do
    consume__829(rest, acc, stack, context, line, offset)
  end

  defp consume__831(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__827(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__827(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__814(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__814(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__811(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__832(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__812(rest, [], stack, context, line, offset)
  end

  defp consume__833(<<"\\", "\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__834(
      rest,
      ["\n", "\\"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 2},
      comb__offset + 2
    )
  end

  defp consume__833(rest, acc, stack, context, line, offset) do
    consume__832(rest, acc, stack, context, line, offset)
  end

  defp consume__834(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__811(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__835(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__833(rest, [], stack, context, line, offset)
  end

  defp consume__836(rest, acc, stack, context, line, offset) do
    consume__837(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__837(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 and x0 !== 92 and x0 !== 10 do
    consume__838(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__837(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__835(rest, acc, stack, context, line, offset)
  end

  defp consume__838(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 and x0 !== 92 and x0 !== 10 do
    consume__840(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp consume__838(rest, acc, stack, context, line, offset) do
    consume__839(rest, acc, stack, context, line, offset)
  end

  defp consume__840(rest, acc, stack, context, line, offset) do
    consume__838(rest, acc, stack, context, line, offset)
  end

  defp consume__839(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__841(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__841(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__811(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__809(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__842(rest, acc, stack, context, line, offset)
  end

  defp consume__811(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__810(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__842(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__843(rest, ["\""] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__842(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__843("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp consume__842(rest, acc, stack, context, line, offset) do
    consume__806(rest, acc, stack, context, line, offset)
  end

  defp consume__843(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__768(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__768(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__844(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__844(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__845(
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

  defp consume__845(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__846(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__765(rest, [], stack, context, line, offset)
  end

  defp consume__847(rest, acc, stack, context, line, offset) do
    consume__848(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__848(rest, acc, stack, context, line, offset) do
    consume__849(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__849(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__850(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__849(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__850(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__849(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__850(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__849(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    consume__846(rest, acc, stack, context, line, offset)
  end

  defp consume__850(rest, acc, stack, context, line, offset) do
    consume__852(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp consume__852(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__853(rest, [" "] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__852(<<"\t", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__853(rest, ["\t"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp consume__852(<<"\n", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__853(
      rest,
      ["\n"] ++ acc,
      stack,
      context,
      {elem(comb__line, 0) + 1, comb__offset + 1},
      comb__offset + 1
    )
  end

  defp consume__852(rest, acc, stack, context, line, offset) do
    consume__851(rest, acc, stack, context, line, offset)
  end

  defp consume__851(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__854(rest, acc, stack, context, line, offset)
  end

  defp consume__853(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    consume__852(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp consume__854(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__855(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__855(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__856(
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

  defp consume__856(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__7(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__7(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    consume__857(
      rest,
      [CssParser.Syntax.Tokenizer.at(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp consume__857(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__3(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__858(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    consume__4(rest, [], stack, context, line, offset)
  end

  defp consume__859(rest, acc, stack, context, line, offset) do
    consume__860(rest, [], [acc | stack], context, line, offset)
  end

  defp consume__860(<<"/*", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__861(rest, acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__860(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__858(rest, acc, stack, context, line, offset)
  end

  defp consume__861(<<"*/", _::binary>> = rest, acc, stack, context, line, offset) do
    consume__862(rest, acc, stack, context, line, offset)
  end

  defp consume__861(rest, acc, stack, context, line, offset) do
    consume__863(rest, acc, stack, context, line, offset)
  end

  defp consume__863(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__864(
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

  defp consume__863(rest, acc, stack, context, line, offset) do
    consume__862(rest, acc, stack, context, line, offset)
  end

  defp consume__864(rest, acc, stack, context, line, offset) do
    consume__861(rest, acc, stack, context, line, offset)
  end

  defp consume__862(<<"*/", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__865(rest, acc, stack, context, comb__line, comb__offset + 2)
  end

  defp consume__862(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    consume__865("", acc, stack, context, comb__line, comb__offset)
  end

  defp consume__862(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    consume__858(rest, acc, stack, context, line, offset)
  end

  defp consume__865(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    consume__866(rest, [] ++ acc, stack, context, line, offset)
  end

  defp consume__866(rest, acc, [_, previous_acc | stack], context, line, offset) do
    consume__3(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp consume__1(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    consume__867(rest, acc, stack, context, line, offset)
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

  defp consume__867(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end
end
