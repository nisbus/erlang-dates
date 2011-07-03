%%%-------------------------------------------------------------------
%%% @author  nisbus <nisbus@gmail>
%%% @copyright (C) 2011, 
%%% @doc
%%% Dates module for handling ranges of dates and other useful date functions.
%%% @end
%%% Created :  2 Jul 2011 by  nisbus <nisbus@gmail.com>
%%%-------------------------------------------------------------------
-module(date_range).

%% API
-export([create_range/3,create_range/4]).

%%%===================================================================
%%% API
%%%===================================================================
create_range(From,To,Frequency, IncludeWeekends) ->
    case IncludeWeekends of 
	true ->
	    create_range(From,To,Frequency);
	false ->
	    Dates = create_range(From,To,Frequency),
	    lists:foldl(fun(X,Acc) ->
				case is_weekend(X) of
				    true ->
					Acc;
				    false ->
					Acc++[X]
				end
			end,[],Dates)
    end.

create_range(From,To,Frequency) ->
    {{Fy,Fm,Fd},{Fhour,Fmin,Fsec}} = From,
    {{Ty,Tm,Td},{Thour,Tmin,Tsec}} = To,
    FromGregor = calendar:datetime_to_gregorian_seconds({{Fy,Fm,Fd},{Fhour,Fmin,Fsec}}),
    ToGregor = calendar:datetime_to_gregorian_seconds({{Ty,Tm,Td},{Thour,Tmin,Tsec}}),
    Dates = case Frequency of
		years ->
		    add_year_until([FromGregor],ToGregor);
		quarters ->
		    add_quarters_until([FromGregor],ToGregor);
		months ->
		    add_months_until(Fd,[FromGregor],ToGregor);
		_ ->
		    Interval = get_interval_seconds(Frequency),
		    lists:seq(FromGregor,ToGregor,Interval)
	    end,
    lists:map(fun(X) ->
		     calendar:gregorian_seconds_to_datetime(X)
	      end, Dates).

%%%===================================================================
%%% Internal functions
%%%===================================================================
add_quarters_until(List,Max) ->
    Last = get_last_date(List),
    {{Y,M,D},{H,Min,Sec}} = calendar:gregorian_seconds_to_datetime(Last),
    Next = case M+3 < 13 of
	       true ->
		   Date = fix_day({Y,M+3,D}),
		   calendar:datetime_to_gregorian_seconds({Date,{H,Min,Sec}});
	       false ->
		   case M of 
		       10 ->
			   calendar:datetime_to_gregorian_seconds({fix_day({Y+1,1,D}),{H,Min,Sec}});
		       11 ->
			   calendar:datetime_to_gregorian_seconds({fix_day({Y+1,2,D}),{H,Min,Sec}});
		       12 ->
			   calendar:datetime_to_gregorian_seconds({fix_day({Y+1,3,D}),{H,Min,Sec}});
		       _ ->
			   calendar:datetime_to_gregorian_seconds({fix_day({Y,M+3,D}),{H,Min,Sec}})		   
		   end
	   end,
    case Next < Max of
	true ->	    
	    add_quarters_until(List++[Next],Max);
	false ->
	    List
    end.

fix_day({Y,M,D}) ->
    Last = calendar:last_day_of_the_month(Y,M),
    case D > Last of
	true ->
	    {Y,M,Last};
	false ->
	    {Y,M,D}
    end.

add_months_until(FirstDay,List,Max) ->
    Last = get_last_date(List),
    {{Y,M,_D},{H,Min,Sec}} = calendar:gregorian_seconds_to_datetime(Last),
    Next = case M +1 < 13 of
	       true ->
		   calendar:datetime_to_gregorian_seconds({fix_day({Y,M+1,FirstDay}),{H,Min,Sec}});
	       false ->
		   calendar:datetime_to_gregorian_seconds({fix_day({Y+1,1,FirstDay}),{H,Min,Sec}})
	   end,
    case Next > Max of
	true ->
	    List;
	false ->
	    add_months_until(FirstDay,List++[Next],Max)
    end.
    
add_year_until(List,Max) ->
    Last = get_last_date(List),
    {{Y,M,D},{H,Min,Sec}} = calendar:gregorian_seconds_to_datetime(Last),
    {{MaxYear,_,_},_} = calendar:gregorian_seconds_to_datetime(Max),
    case MaxYear < Y+1 of
	true ->
	    List;
	false ->
	    Next = calendar:datetime_to_gregorian_seconds({{Y+1,M,D},{H,Min,Sec}}),
	    add_year_until(List++[Next],Max)
    end.

get_last_date(List) ->
    case List of 
	[H|[]] ->
	    H;
	[_H|_T] ->
	    hd(lists:reverse(List))
    end.

get_interval_seconds(Frequency) ->
    case Frequency of
	seconds ->
	    1;
	minutes ->
	    60;
	hours ->
	    60*60;
	days ->
	    60*60*24;
	weeks ->
	    60*60*24*7
    end.

is_weekend(Date) ->
    {D,_} = Date,
    Day = calendar:day_of_the_week(D),
    case Day of
	7 ->
	    true;
	6 ->
	    true;
	_ ->
	    false
    end.
