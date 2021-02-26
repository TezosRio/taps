<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>

<cfset reload = true>
<cfset totalSum = 0>
<cfset sent = false>
<cfset isSending = false>
<cfset isTableShowing = false>
<cfset errors = "">
<cfset userHasNoPermissionToOpenFile = false>
<cfset session.hasChosenFile = false>

<cfif #isDefined("url.s")#>
   <cfif #url.s# EQ true>
      <cfset #session.hasChosenFile# = true>
   </cfif>
</cfif>

<cfif #isDefined("session.hasChosenFile")#>
   <cfif #session.hasChosenFile# EQ true>
      <cfset session.hasChosenFile = false> 
      <cfif #isDefined("form")#>
         <cfif #StructIsEmpty(form)# EQ true>
            <cfset userHasNoPermissionToOpenFile = true>
         <cfelse>
            <cfset isTableShowing = true>
         </cfif>
      </cfif>
   <cfelse>
      <cfset userHasNoPermissionToOpenFile = false>
   </cfif>
</cfif>
<cfset StructDelete(session, 'hasChosenFile')>

<!DOCTYPE html>
<html lang="en">
   <head>
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
      <meta http-equiv="cache-control" content="no-cache">

      <!-- CSS Bootstrap-->
      <link rel="stylesheet" type="text/css" href="css/bootstrap.min.css"> 
      <!-- CSS Page-->
      <link rel="stylesheet" type="text/css" href="css/estilo.css">

      <script src="js/jquery-3.2.1.min.js"></script>

      <script language="javascript">
         var reload = true;

        $(document).ready(function()
        {

            $(".sendBatch").click(function(){

               if (confirm('Are you sure to send this list of operations as a batch transaction?\nThis cannot be undone!'))
               {

                  // Shows wait message.
                  $("#idWait").html("Batch operation sent. Waiting for blockchain confirmation...");

                  // Sets IsSending to true.
                  document.getElementById("idIsSending").value=true;

                  // Sets IsTableShowing to false.
                  document.getElementById("idIsTableShowing").value=false;

                  // Turn button inactive.
                  $("#btnSend").attr("disabled", true);

                  // Submit form.
                  document.form.action = "csvBatchSend.cfm";
                  document.form.submit();

               }
               else
               {
                  alert('Operation cancelled!');
               }
            });
        });

      </script>

      <script language="javascript">
         function jump(h)
         {
            if (h === "start")
            {  
               window.parent.parent.scrollTo(0,0);
            }
            else
            {
               window.parent.parent.scrollTo(0,500);
            }
         }
      </script>

      <style>
	   .error
	   {
              font-size:22px;
	      color:red;
	      border:hidden;
	      cursor:default;
	   }
	   .sent
	   {
              font-size:22px;
	      color:black;
	      border:hidden;
	      cursor:default;
	   }

           .blink_me {
              animation: blinker 1s linear infinite;
              font-size:22px;
	      color:black;
	      border:hidden;
	      cursor:default;
           }

           @keyframes blinker {
           50% {
                 opacity: 0;
               }
           }
	</style>

   </head>

   <body>

      <section class="box-content-rewards">
         <cfoutput>
     
         <h1 class="title-baker">
            CSV Batch
         </h1>                

         <!--- Check if all data were fetched --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

         <cfif #settings.recordCount# GT 0>

               <cfif #settings.status# EQ true>


		       <cfset reload = false>
                       
                       <br>
                       Here you can import a standard CSV file from a spreadsheet to use as source for a MANUAL batch operation.<br>
                       Operations made on this feature will always be sent, even if TAPS STATUS is set to OFF or SIMULATION.<br>
                       This feature was funded by and conceived in collaboration with <a href="https://www.cryptodelegate.com/" target="_new"><u>CryptoDelegate</u></a> Baker.<br>
                       <br>
                       CSV File Requirements:<br>
                       <br>
                       1) Ensure that you have read permission on the CSV file.<br>
                       2) The CSV file delimiter character must be or a comma (",") or a semicolon (";").<br>
                       3) The CSV file must contain only two columns, with no headers.<br>
                       4) The first column of sheet is for destination adresses (text), one per row.<br>
                       5) Second column of sheet is for amounts in militez (1000000 = 1 tez), one per row<br>
                       
                       <br>
                       After choosing the file, carefully check the data on the table that will be displayed below.<br>
                       All actions will show a confirmation prompt after pressing the operation button, for safety.<br>
                       After use, wait at least 1 minute and check blockchain for results.<br>
                       <br>

                       <cfform name="form" id="fileForm" action="csvBatch.cfm?s=true" method="post" enctype="multipart/form-data">
                          Choose CSV file and then hit SEND BATCH button.<br><br>
                          <cfinput type="file" name="fileInput" id="btnFileInput" style="display: none;" accept=".csv,.CSV,.txt,.TXT">

                          <input type="button" value="Browse..." onclick="document.getElementById('btnFileInput').click();" />
                          <span class="error" id="idPermission" style="padding:10px;">
                             <cfif #userHasNoPermissionToOpenFile# EQ true>
                                <cfset userHasNoPermissionToOpenFile = false>
                                <cfset #session.hasChosenFile# = false>
                                Not enough permissions to open this file. Change its properties and try again.
                             </cfif>
                          </span>
                          <input type="hidden" name="isTableShowing" id="idIsTableShowing" value="#isTableShowing#">

                          <script language="javascript">
                             document.getElementById("btnFileInput").onchange = function()
                             {

                                // Sets IsTableShowing to true.
                                document.getElementById("idIsTableShowing").value=true;

                                document.getElementById("fileForm").submit();

                             };

                             document.getElementById("btnFileInput").onclick = function()
                             {
                                // Sets IsTableShowing to true.
                                document.getElementById("idIsTableShowing").value=true;

                             };

                          </script>

                          <cfset totalSum = 0>




                          <cfif isDefined("form.fileInput") and #isSending# EQ false>                            



                          <cftry>
                             <!--- Clears the session variable --->  
                             <cfset #session.customBatch# = "">
                             
                             <!--- Sets the line delimiter --->
                             <cfset lineDelimiter = #chr(10)#>



                             <!--- Reads CSV file --->
                             <cffile action="read" file="#form.fileInput#" variable="myFile">

                             <!--- Cleans CSV file for compatibility with different types of line-breaks --->
                             <cfset csvfile = #myFile.ReplaceAll("\r?\n", lineDelimiter)# />

                             <!--- Creates in-memory database table --->
                             <cfset queryLines = queryNew("address,amount","varchar,bigInt")>

                             <!--- Populates in-memory database table with csv data --->
                             <cfloop index="index" list="#csvfile#" delimiters="#lineDelimiter#"> 
                                <cfset QueryAddRow(queryLines, 1)> 
                                <cfset QuerySetCell(queryLines, "address", javacast("string", "#listgetAt(index,1, ',;')#" ))> 
                                <cfset QuerySetCell(queryLines, "amount", javacast("bigInteger", #listgetAt(index,2, ',;')# ))>                             
                             </cfloop>

                             <!--- Saves data on session variable --->
                             <cfset #session.customBatch# = #queryLines#>

                             <br><br>
              	             <table class="table table-taps-alt">
                                <thead class="head-table-taps">
                                   <tr>
                                      <th style="text-align:center;" scope="col"></th>
                                      <th style="text-align:left;" scope="col">Destination Address</th>
                                      <th style="text-align:center;" scope="col">Amount</th>
                                   </tr>
                                 </thead>

                                 <tbody>
  
                                 <cfloop from="1" to="#queryLines.recordCount#" index="i"> 
                                    <tr>
                                       <td style="font-size: 0.9em;" align="center">#i#</td>
                                       <td style="font-size: 0.9em;" align="left">#queryLines.address[i]#</td>
                                       <td style="font-size: 0.9em;" align="center">#LSNumberFormat((queryLines.amount[i]) / application.militez, '999,999,999,999.999999')#&nbsp;#application.tz#</td>
                                       <cfset totalSum = totalSum + #queryLines.amount[i]#>
                                    </tr>
                                 </cfloop>

                                 <tr>
                                    <td align="left">Total</td>
                                    <td align="left"></td>
                                    <td align="center">#LSNumberFormat(totalSum / application.militez, '999,999,999,999.999999')#&nbsp;#application.tz#</td>
                                 </tr>

                                </tbody>
                             </table>

                             <br>
                             <input type="hidden" name="isSending" id="idIsSending" value="false">
                             <input type="button" class="sendBatch" id="btnSend" value="SEND BATCH">
                             
                             <span class="blink_me" id="idWait" style="padding:10px;"></span>

                          <cfcatch>
                             <br><br>
                             <span class="error">
                             Some error occured while trying to read your file.<br>
                             Please check file contents to see if it meet required conditions, then try again.<br>
                             </span>
                             <br><br>
                          </cfcatch>
                          </cftry>

                          </cfif>  

                       </cfform>

                <cfelse>
                   <br><br><br><br><br><br>
                   <table width="100%">
                      <tr><td align="center"><img src="imgs/spin.gif" width="50" height="50"><br></td></tr>
                      <tr style="line-height:30px;text-align:center;"><td align="center">Fetching... Please wait</td></tr>
                   </table>
                </cfif>

         <cfelse>
            <br>
            There is no configuration saved on settings.<br>
            Please go to SETUP first.<br>
         </cfif>

         <cfif #isTableShowing# EQ true>
            <script language="javascript">
               $(document).ready(function(){
                  jump("tableData");
               });
            </script>
         <cfelse>
            <script language="javascript">
               $(document).ready(function(){
                  jump("start");
               });
            </script>
         </cfif>

      </cfoutput>

      <a id="tableData" class="anchor"></a>

</section>

<cfif #reload# EQ true>
   <!---  Reload page until fetch completed --->
   <script language="javascript">
      setTimeout(function(){ location.reload(); }, 5000);
   </script>
</cfif>

</body>
</html>

