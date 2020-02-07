<cfcontent type="application/pdf">
<cfset subTotalSum = 0>
<cfset totalSum = 0>
<cfset myCycle = "">

<cfif isDefined("url.myCycle")>
   <cfset myCycle = "#url.myCycle#">
</cfif>

<!--- Get delegators payments from local database ---> 
<cfinvoke component="components.database" method="getDelegatorsPayments" returnVariable="delegatorsPayments">

<!--- Use a query of queries to modify the display order --->
<cfquery name="delegators_cycle_ordered" dbtype="query">
   select BAKER_ID, CYCLE, ADDRESS, DATE, RESULT, TOTAL
   from delegatorsPayments
   <cfif #len(myCycle)# GT 0>
   where CYCLE = #myCycle#
   </cfif>
   order by CYCLE, BAKER_ID, TOTAL DESC, ADDRESS, DATE, RESULT 
</cfquery>

<cfdocument format="PDF" pageType="A4" overwrite="true">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<head>
   <style type="text/css">
      @font-face
         {font-family:"Times";   }
      @font-face
         {font-family:"Arial";   }
      @font-face
         {font-family:"Courier";   }
      @font-face
        {font-family:"Helvetica";   }

      table
      { 
         border-spacing: 10px;
         border-collapse: separate;
      }

   </style>
</head>

<body>
   <cfoutput>
   <cfdocumentitem type="header">
      <img src="imgs/taps_logo_dourada.png" width="140" style="margin-left:-12px;padding-bottom:-3px;"><br>
      <span style="font-size:6pt;font-family:Courier;">Tezos Automatic Payment System</span>
      <br><br><br>
      <i>Delegators Payments</i>
   </cfdocumentitem>
   </cfoutput>

   <cfdocumentsection>
      <center>
      <table>
      <cfoutput query="#delegators_cycle_ordered#" group="cycle"> 
            <tr>
               <th colspan="4" align="center" style="height:10px;font-size:9pt;font-family:Courier;">Cycle #delegators_cycle_ordered.cycle#</th>
               <td></td>
               <td></td>
               <td></td>
            </tr>

            <tr><td colspan="4"><hr></td></tr>

            <tr>
               <th style="text-align:left;font-size:9pt;font-family:Courier;">Address</th>
               <th style="text-align:center;font-size:9pt;font-family:Courier;">Date</th>
               <th style="text-align:center;font-size:9pt;font-family:Courier;">Result</th>
               <th style="text-align:center;font-size:9pt;font-family:Courier;">Amount</th>
            </tr>

            <cfoutput>
               <tr>
                 <td align="left" style="font-size:9pt;font-family:Courier;">#delegators_cycle_ordered.address#</td>
                 <td align="center" style="font-size:9pt;font-family:Courier;">#DateFormat(delegators_cycle_ordered.date, 'MM/DD/YYYY')#</td>
                 <td align="center" style="font-size:9pt;font-family:Courier;">#delegators_cycle_ordered.result#</td>
                 <td align="center" style="font-size:9pt;font-family:Courier;">#LSNumberFormat(delegators_cycle_ordered.total / application.militez, '999,999,999,999.999999')#</td>
               </tr>

               <!--- Calculate totals --->
               <cfset subTotalSum = subTotalSum  + #delegators_cycle_ordered.total#>
               <cfset totalSum = totalSum + #delegators_cycle_ordered.total#>
            </cfoutput>

            <tr><td colspan="4"><hr></td></tr>
       
            <tr>
               <td align="left" style="font-size:9pt;font-family:Courier;">Sub-total</td>
               <td></td>
               <td align="center"></td>
               <td align="center" style="font-size:9pt;font-family:Courier;" >#LSNumberFormat(subtotalSum / application.militez, '999,999,999,999.999999')#&nbsp;XTZ</td>
            </tr>

            <cfset subTotalSum = 0>
            <br><br>
         </cfoutput>
         </table>

         <cfoutput>
         <table>
            <tr><td colspan="4"><hr></td></tr>
            <tr>
               <th align="left" style="font-size:9pt;font-family:Courier;">Total Sum</th>
               <th></th>
               <th></th>
	       <th align="right" style="font-size:9pt;font-family:Courier;" >#LSNumberFormat(totalSum / application.militez, '999,999,999,999.999999')#&nbsp;XTZ</th>
            </tr>

      </center>
      </table>
      </cfoutput>
   </cfdocumentsection>

   <cfoutput>
      <cfdocumentitem type="footer">
         <h6 style="text-align:center;">Page #cfdocument.currentPageNumber# of #cfdocument.totalPageCount#</h6>
      </cfdocumentitem>
   </cfoutput>

</body>
</html>
</cfdocument>

