         <cfoutput>

         <h1 class="title-baker">
           Delegators Payments
         </h1>                
  
         <!--- Check if all data were fetched from TzScan --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

         <cfif #settings.recordCount# GT 0>
            <cfif #settings.status# EQ true>

               <cfset reload = false>

               <!--- Get delegators payments from local database ---> 
               <cfinvoke component="components.database" method="getDelegatorsPayments" returnVariable="delegatorsPayments">

               <cfif #delegatorsPayments.recordCount# GT 0>
                  <cfform name="form" action="payments.cfm" method="post">
                     <table class="table table-taps-rewards">
                     <thead class="head-table-taps">
                        <tr>
                           <th style="text-align:center;" scope="col">Cycle</th>
                           <th style="text-align:center;" scope="col">Address</th>
                           <th style="text-align:center;" scope="col">Date</th>
                           <th style="text-align:center;" scope="col">Result</th>
                           <th style="text-align:center;" scope="col">Total</th>
                        </tr>
                     </thead>

                     <tbody>

		        <cfloop from="1" to="#delegatorsPayments.recordCount#" index="i"> 
		           <tr>
		              <td align="center" >#delegatorsPayments.cycle[i]#</td>
		              <td align="center" >#delegatorsPayments.address[i]#</td>
		              <td align="center" >#DateFormat(delegatorsPayments.date[i], 'MM/DD/YYYY')#</td>
		              <td align="center" >#delegatorsPayments.result[i]#</td>
		              <td align="center" >#LSNumberFormat(delegatorsPayments.total[i], '999,999,999,999.99')#&nbsp;#application.tz#</td>
                              <cfset totalSum = totalSum + #delegatorsPayments.total[i]#>
		             
		           </tr>
		        </cfloop>
                        <tr>
                           <td></td>
                           <td align="left">Total Sum</td>
                           <td></td>
                           <td align="center"></td>
		           <td align="center" >#LSNumberFormat(totalSum, '999,999,999,999.99')#&nbsp;#application.tz#</td>
                        </tr>
                        <tr>
                           <td></td>
                           <td></td>
                           <td></td>
                           <td>Reports:</td>
                           <td><img scr="./imgs/pdf.jpg" onclick="javascript:window.open('report.cfm');"></td>
                        </tr>
		        <cfinput name="address" type="hidden" value="">
		        <cfinput name="fee" type="hidden" value="">
 		        <cfinput name="saveit" type="hidden" value="0"> 
		     </table>
		  </cfform>

