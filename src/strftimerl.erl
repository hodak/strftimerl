%% =============================================================================
%% @author Gavin M. Roy <gavinmroy@gmail.com>
%% @copyright 2015-2016
%% @end
%% =============================================================================
-module(strftimerl).
-author("gavinr").

%% API
-export([format/2]).

%% Export all for unit tests
-ifdef(TEST).
-compile(export_all).
-endif.

-define(CONVERSION_SPECIFICATIONS, ["%C", "%d", "%D", "%F", "%g", "%G", "%H",
                                    "%I", "%j", "%k", "%l", "%m", "%M", "%n",
                                    "%p", "%P", "%r", "%R", "%s", "%S", "%t",
                                    "%T", "%u", "%V", "%w", "%y", "%Y"]).

-spec format(Value :: string(), Datetime :: calendar:datetime()) -> string().
%% @spec format(Value, Datetime) -> Result
%% where
%%    Value = string()
%%    Datetime = datetime()
%%    Result = string()
%% @end
%% @doc Format a date and time. Supported conversion specifications include:
%%
%% <table>
%%  <thead>
%%   <tr>
%%    <th><b>Specifier</b></th><th><b>Meaning</b></th>
%%   </tr>
%%  </thead>
%%  <tbody>
%%   <tr><td>``%C''</td><td>The century number (year/100) as a 2-digit integer.</td></tr>
%%   <tr><td>``%d''</td><td>The day of the month as a decimal number (range 01 to 31).</td></tr>
%%   <tr><td>``%D''</td><td>Equivalent to ``%m/%d/%y''.</td></tr>
%%   <tr><td>``%F''</td><td>Equivalent to ``%Y-%m-%d''.</td></tr>
%%   <tr><td>``%G''</td><td>The ISO 8601 week-based year with century as a decimal number.</td></tr>
%%   <tr><td>``%g''</td><td>Like ``%G'', but without century, that is, with a 2-digit year (00-99).</td></tr>
%%   <tr><td>``%H''</td><td>The hour as a decimal number using a 24-hour clock (range 00 to 23).</td></tr>
%%   <tr><td>``%I''</td><td>The hour as a decimal number using a 12-hour clock (range 01 to 12).</td></tr>
%%   <tr><td>``%j''</td><td>The day of the year as a decimal number (range 001 to 366).</td></tr>
%%   <tr><td>``%k''</td><td>The hour (24-hour clock) as a decimal number (range 0 to 23); single digits are preceded by a blank.  (See also ``%H'')</td></tr>
%%   <tr><td>``%l''</td><td>The hour (12-hour clock) as a decimal number (range 1 to 12); single digits are preceded by a blank.  (See also ``%I'')</td></tr>
%%   <tr><td>``%m''</td><td>The month as a decimal number (range 01 to 12).</td></tr>
%%   <tr><td>``%M''</td><td>The minute as a decimal number (range 00 to 59).</td></tr>
%%   <tr><td>``%n''</td><td>A newline character.</td></tr>
%%   <tr><td>``%p''</td><td>Either "AM" or "PM" according to the given time value. Noon is treated as "PM" and midnight as "AM".</td></tr>
%%   <tr><td>``%P''</td><td>Like %p but in lowercase: "am" or "pm".</td></tr>
%%   <tr><td>``%r''</td><td>The time in a.m. or p.m. notation. This is equivalent to ``%I:%M:%S %p''.</td></tr>
%%   <tr><td>``%R''</td><td>The time in 24-hour notation (``%H:%M'').  For a version including the seconds, see ``%T'' below.</td></tr>
%%   <tr><td>``%s''</td><td>The number of seconds since the Epoch, 1970-01-01 00:00:00 +0000 (UTC).</td></tr>
%%   <tr><td>``%S''</td><td>The second as a decimal number (range 00 to 60).  (The range is up to 60 to allow for occasional leap seconds.)</td></tr> 
%%   <tr><td>``%t''</td><td>A tab character.</td></tr>
%%   <tr><td>``%T''</td><td>The time in 24-hour notation (``%H:%M:%S'').</td></tr>
%%   <tr><td>``%u''</td><td>The day of the week as a decimal, range 1 to 7, Monday being 1.  See also ``%w''.</td></tr>
%%   <tr><td>``%V''</td><td>The ISO 8601 week number of the current year as a decimal number, range 01 to 53, where week 1 is the first week that has at least 4 days in the new year.</td></tr>
%%   <tr><td>``%w''</td><td>The day of the week as a decimal, range 0 to 6, Sunday being 0.  See also ``%u''.</td></tr>
%%   <tr><td>``%y''</td><td>The year as a decimal number without a century (range 00 to 99).</td></tr>
%%   <tr><td>``%Y''</td><td>The year as a decimal number including the century.</td></tr>
%%  </tbody>
%% </table>
%%
%% @end
format(Value, Datetime) ->
  format(?CONVERSION_SPECIFICATIONS, Datetime, Value).

-spec format(Specifications :: [string()], Datetime :: calendar:datetime(), Value :: string()) -> string().
%% @private
%% @spec format(Specifications, Datetime, Value) -> string()
%% where
%%    Specifications = [string()]
%%    Value = string()
%%    Datetime = datetime()
%% @doc Return a interpolated version of the path string.
%% @end
%%
format([], _, Value) -> Value;

format([H|T], Datetime, Value) when H == "%C" ->
  {{V, _, _}, _} = Datetime,
  format(T, Datetime, replace(H, Value, lists:sublist(as_string(V), 1, 2)));

format([H|T], Datetime, Value) when H == "%d" ->
  {{_, _, D},_} = Datetime,
  V = lists:flatten(io_lib:format("~2..0B", [D])),
  format(T, Datetime, replace(H, Value, as_string(V)));

format([H|T], Datetime, Value) when H == "%D" ->
  {{Y, M, D},_} = Datetime,
  V = lists:flatten(io_lib:format("~2..0B/~2..0B/~4..0B", [M, D, Y])),
  format(T, Datetime, replace(H, Value, as_string(V)));

format([H|T], Datetime, Value) when H == "%F" ->
  {{Y, M, D},_} = Datetime,
  V = lists:flatten(io_lib:format("~4..0B-~2..0B-~2..0B", [Y, M, D])),
  format(T, Datetime, replace(H, Value, as_string(V)));

format([H|T], Datetime, Value) when H == "%g" ->
  {Date,_} = Datetime,
  {Y, _} = calendar:iso_week_number(Date),
  format(T, Datetime, replace(H, Value, lists:nthtail(2, as_string(Y))));

format([H|T], Datetime, Value) when H == "%G" ->
  {Date,_} = Datetime,
  {Y, _} = calendar:iso_week_number(Date),
  format(T, Datetime, replace(H, Value, as_string(Y)));

format([H|T], Datetime, Value) when H == "%H" ->
  {_,{V,_,_}} = Datetime,
  Hour = lists:flatten(io_lib:format("~2..0B", [V])),
  format(T, Datetime, replace(H, Value, Hour));

format([H|T], Datetime, Value) when H == "%I" ->
  {_,{V,_,_}} = Datetime,
  Hour = case V > 12 of
    true  -> lists:flatten(io_lib:format("~2..0B", [V - 12]));
    false -> lists:flatten(io_lib:format("~2..0B", [V]))
  end,
  format(T, Datetime, replace(H, Value, Hour));

format([H|T], Datetime, Value) when H == "%j" ->
  {Date,_} = Datetime,
  {_, W} = calendar:iso_week_number(Date),
  V = ((W-1) * 7) + (calendar:day_of_the_week(Date) - 1),
  Hour = lists:flatten(io_lib:format("~3..0B", [V])),
  format(T, Datetime, replace(H, Value, Hour));

format([H|T], Datetime, Value) when H == "%k" ->
  {_,{V,_,_}} = Datetime,
  Hour = lists:flatten(io_lib:format("~2.. B", [V])),
  format(T, Datetime, replace(H, Value, Hour));

format([H|T], Datetime, Value) when H == "%l" ->
  {_,{V,_,_}} = Datetime,
  Hour = case V > 12 of
    true  -> lists:flatten(io_lib:format("~2.. B", [V - 12]));
    false -> lists:flatten(io_lib:format("~2.. B", [V]))
  end,
  format(T, Datetime, replace(H, Value, Hour));

format([H|T], Datetime, Value) when H == "%m" ->
  {{_, M, _},_} = Datetime,
  V = lists:flatten(io_lib:format("~2..0B", [M])),
  format(T, Datetime, replace(H, Value, as_string(V)));

format([H|T], Datetime, Value) when H == "%M" ->
  {_,{_, M, _}} = Datetime,
  V = lists:flatten(io_lib:format("~2..0B", [M])),
  format(T, Datetime, replace(H, Value, as_string(V)));

format([H|T], Datetime, Value) when H == "%n" ->
  format(T, Datetime, replace(H, Value, "\n"));

format([H|T], Datetime, Value) when H == "%p" ->
  {_,{V,_,_}} = Datetime,
  Hour = case V > 12 of
    true  -> "PM";
    false -> "AM"
  end,
  format(T, Datetime, replace(H, Value, Hour));

format([H|T], Datetime, Value) when H == "%P" ->
  {_,{V,_,_}} = Datetime,
  Hour = case V > 12 of
    true  -> "pm";
    false -> "am"
  end,
  format(T, Datetime, replace(H, Value, Hour));

format([H|T], Datetime, Value) when H == "%r" ->
  {_,{Hr, M, S}} = Datetime,
  {Hour, I} = case Hr > 12 of
    true  -> {Hr - 12, "PM"};
    false -> {Hr, "AM"}
  end,
  V = lists:flatten(io_lib:format("~2..0B:~2..0B:~2..0B ~s", [Hour, M, S, I])),
  format(T, Datetime, replace(H, Value, as_string(V)));

format([H|T], Datetime, Value) when H == "%R" ->
  {_,{Hr, M, _}} = Datetime,
  V = lists:flatten(io_lib:format("~2..0B:~2..0B", [Hr, M])),
  format(T, Datetime, replace(H, Value, as_string(V)));

format([H|T], Datetime, Value) when H == "%s" ->
  V = calendar:datetime_to_gregorian_seconds(Datetime) - 62167219200,
  format(T, Datetime, replace(H, Value, as_string(V)));

format([H|T], Datetime, Value) when H == "%S" ->
  {_,{_, _, S}} = Datetime,
  V = lists:flatten(io_lib:format("~2..0B", [S])),
  format(T, Datetime, replace(H, Value, as_string(V)));

format([H|T], Datetime, Value) when H == "%t" ->
  format(T, Datetime, replace(H, Value, "\t"));

format([H|T], Datetime, Value) when H == "%T" ->
  {_,{Hr, M, S}} = Datetime,
  V = lists:flatten(io_lib:format("~2..0B:~2..0B:~2..0B", [Hr, M, S])),
  format(T, Datetime, replace(H, Value, as_string(V)));

format([H|T], Datetime, Value) when H == "%u" ->
  {Date,_} = Datetime,
  V = calendar:day_of_the_week(Date),
  format(T, Datetime, replace(H, Value, as_string(V)));

format([H|T], Datetime, Value) when H == "%V" ->
  {Date,_} = Datetime,
  {_, W} = calendar:iso_week_number(Date),
  V = lists:flatten(io_lib:format("~2..0B", [W])),
  format(T, Datetime, replace(H, Value, V));

format([H|T], Datetime, Value) when H == "%w" ->
  {Date,_} = Datetime,
  V = case calendar:day_of_the_week(Date) of
    7 -> 0;
    O -> O
  end,
  format(T, Datetime, replace(H, Value, as_string(V)));

format([H|T], Datetime, Value) when H == "%y" ->
  {{Y, _, _},_} = Datetime,
  format(T, Datetime, replace(H, Value, as_string(lists:nthtail(2, as_string(Y)))));

format([H|T], Datetime, Value) when H == "%Y" ->
  {{V, _, _},_} = Datetime,
  format(T, Datetime, replace(H, Value, as_string(V)));

format([H|T], Datetime, Value) ->
  error_logger:warning_msg("Unsupported specifier ~s", [H]),
  format(T, Datetime, Value).


-spec as_string(Needle :: atom() | integer() | binary() | list()) -> string().
%% @private
%% @spec as_string(Value) ->string()
%% where Value = list()|integer()
%% @doc Return the value as a list
%% @end
%%
as_string([]) -> undefined;
as_string(Value) when is_atom(Value) =:= true -> atom_to_list(Value);
as_string(Value) when is_binary(Value) =:= true -> binary_to_list(Value);
as_string(Value) when is_integer(Value) =:= true -> integer_to_list(Value);
as_string(Value) when is_list(Value) =:= true -> Value;
as_string(Value) -> Value.


-spec replace(Needle :: string(), Haystack :: string(), Value :: string()) -> string().
%% @private
%% @doc Replace Needle with Value in Haystack
%% @spec replace(Needle, Haystack, Value) -> string()
%% where
%%    Needle = string()
%%    Haystack = string()
%%    Value = string()
%% @end
%%
replace(Needle, Haystack, Value) ->
  case string:str(Haystack, Needle) of
    0 -> Haystack;
    P ->
      New = string:left(Haystack, P - 1) ++ Value ++ string:right(Haystack, length(Haystack) - P - 1),
      replace(Needle, New, Value)
  end.
