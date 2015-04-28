<cfcomponent displayname="APR and IRR Calculator" output="false">

	<cffunction name="calculateNPV" access="private" hint="Calculate the Net Present Value for a cashflow value, the current month in the cashflow" output="false">
		<cfargument name="cashFlowValue" type="Numeric" required="true" />
		<cfargument name="paymentMonth" type="Numeric" required="true" />
		<cfargument name="estimatedPercentage" type="Numeric" required="true" />
		
		<cfset var NPV = arguments.cashFlowValue/((1+arguments.estimatedPercentage/100)^arguments.paymentMonth) />

		<cfreturn NPV />
	</cffunction>


	<cffunction name="calculateIRR" access="public" returntype="numeric" hint="Calculates the Internal Rate of Return for a given cashflow" output="false">
		<cfargument name="arrCashFlow" type="Array" required="true" hint="Array of payments to be made over the payment term" />
		
		<cfscript>
			// We're using a binary search to find an IRR (break even point) that meets our needs based on the cashflow
			var guess=1;
			var prevGuess = 0;
			var irr = 0;
			var sum = 999;
			var arrNPV = [];
			var iterationCount = 0;
			var i = 0;
			var guessMid = 0;
			
			do {
				iterationCount++;
				
				// Calculate the Net Present Value for each item in the cash flow with the current IRR guess.
				for (i=1;i<=ArrayLen(arguments.arrCashFlow);i++) {
					arrNPV[i] = calculateNPV(arrCashFlow[i],i-1,guess);
				}
				
				sum = NumberFormat(arraySum(arrNPV),"999999.99");
				
				if (sum lt 0) { // This guess is too high
					guessMid = (guess-prevGuess)/2;
					prevGuess = guess;
					guess = guess-Abs(guessMid);
				} else	if (sum gt 0){ // This guess is too low
					guessMid = (prevGuess-guess)/2;
					prevGuess = guess;
					guess = guess+abs(guessMid);
				} else if (sum EQ 0) IRR = guess; // BINGO!!
				
			} while (abs(sum) != 0 AND iterationCount LT 25);  
			// It is possible to never get a zero sum for NPV values on a given guess, so we need to stop somewhere. 
			// An iteration of 25 seemed to give good results without affecting performance.
		</cfscript>
		
		<cfreturn IRR />
	</cffunction>


	<cffunction name="generateCashFlow" access="public" returnType="array" hint="generates a cash flow over the payment term for a given advance, monthly payment and any additional fees." output="false">
		<cfargument name="advance" type="numeric" required="true" />
		<cfargument name="payment" type="Numeric" required="true" />
		<cfargument name="term" type="numeric" required="true" />
		<cfargument name="acceptanceFee" type="numeric" required="false" default="0" />
		<cfargument name="optionFee" type="numeric" required="false" default="0" />
		
		<cfscript>
			var arrCashFlow = [];
			var i = 0;

			// first item in the cash flow is the advance that was given 
			arrCashFlow[1] = -arguments.advance; 

			// rest of cash flow is payments against the advance
			for (i=1;i<=arguments.term;i++) {
			
				if (i == 1) arrCashFlow[i+1] = arguments.payment+arguments.acceptanceFee;  // include acceptance fee in payment scheme
				if (i == arguments.term) arrCashFlow[i+1] = arguments.payment+arguments.optionFee; // include option fee at end of scheme
				if (i < arguments.term && i != 1) arrCashFlow[i+1] = arguments.payment;
			}
		</cfscript>
		
		<cfreturn arrCashFlow />
	</cffunction>


	<cffunction name="calculatePayment" access="public" returntype="numeric" output="false" hint="Calculates the monthly payment based on the advance, flat interest rate and payment term">
		<cfargument name="advance" type="numeric" required="true" hint="Value of advance to be repaid." />
		<cfargument name="flatrate" type="numeric" required="true" hint="Flatrate interest percentage for repayment" />
		<cfargument name="term" type="numeric" default="36" hint="Number of months over which the advance will be repaid." /> 
		
		<cfset var payment = (arguments.advance*(1+(arguments.flatrate/100)*arguments.term/12))/arguments.term />

		<cfreturn payment />
	</cffunction>


	<cffunction name="calculateAPR" access="public" returntype="numeric" hint="Calculates the APR from a given IRR">
		<cfargument name="IRR" type="numeric" required="true" />
		
		<cfreturn (1+(arguments.IRR/100))^12-1 />
	</cffunction>

</cfcomponent>
