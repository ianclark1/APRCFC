
<cfscript>
oAPR = createObject("component","APR");

advance = 20000;
term = 60;
acceptancefee = 199;
optionfee = 99;
InterestRate = 5.1;

monthlyPayment = oApr.calculatePayment(advance,InterestRate,term);

cashFlow = oApr.generateCashFlow(advance,monthlyPayment,term,acceptanceFee,optionFee);

IRR = oAPR.calculateIRR(cashFlow);
APR = oAPR.calculateAPR(IRR);

writedump(variables);

</cfscript>

 