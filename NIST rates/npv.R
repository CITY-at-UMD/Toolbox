# npv calculates the net present value given a discount rate, and column vector of cash flows
# cash flow starts in year 0
# 
npv <- function(discount.rate, cash.flow = c(0), n=length(cash.flow)-1) {
	n.flag = length(cash.flow)-1
	if (n < n.flag) { # user-value n below cash.flow length 
	  cash.flow = cash.flow[0:n+1]
	  print("Warning: length of cash.flow is greater than time interval n.  Omitted cash flow values beyond n.")
	}	
	if (n > n.flag) { # user-value n above cash.flow length 
	  cash.flow = c(cash.flow,rep(0,n-length(cash.flow)+1))
	  print("Warning: length of cash.flow is less than time interval n.  Assumed 0 cash flow for extra time intervals.")
	} 	

    result <- sum(cash.flow * (1/(1+discount.rate))^(0:(n)))
	return(result)
	}