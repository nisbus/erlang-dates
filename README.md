This will hopefully extend to some useful functions for DateTime manipulation in Erlang.  
  
For now it only supports creating ranges of dates given the FromDate, ToDate and Frequency.  
HOWTO:  
  
get_range(FromDate,ToDate,Frequency)  
  
returns a list of dates ranging from the FromDate to the ToDate in the specified frequency.  
  
get_range(FromDate,ToDate,Frequency,IncludeWeekends)  
  
The same as the first one only omitting weekends (when IncludeWeekends is false).  
  
TODO:  
  
Add more date time functions that are missing from the erlang:calendar.