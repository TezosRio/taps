<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>


<cfset sent = false>
<cfset opHash = "">
<cfset error = "">

<cfif #isDefined("form.isSending")#>
   <cfif #form.isSending# EQ true>

      <!--- Sends the BATCH operation --->
      
        <cftry>
           <cfinvoke component="components.taps" method="sendCustomBatch" batch="#session.customBatch#" returnvariable="opHash">
           <cfset sent = true>
        <cfcatch>
           <cfset sent = false>
           <cfset error = "#cfcatch.detail# - #cfcatch.message# - #opHash#">
        </cfcatch>
        </cftry> 

        <!--- Clears the session variable --->
        <cfset #session.customBatch# = "">
      
      <!--- end of sending ---> 

   </cfif>
</cfif>


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
              font-size:18px;
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

           .link
           {
              text-decoration: underline; 
              cursor:pointer;
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

               <cfif #sent# EQ true>
		  <br><br>
		  <span class="sent">
		  Operation was received by Tezos blockchain.<br>
		  Click hash below to check results in a block explorer:<br>
                  <br><br>
                  <span class="link" onclick="window.open('#application.blockExplorerAlt##opHash#');">#opHash#</span>
		  <br><br>
               <cfelse>
		  <br>
		  <span class="error">
		  Some error occured while trying to send your batch operation.<br>
		  Please check status in a block explorer and try again.<br>
                  <br>
                  #error#<br>
                  <br>
		  </span>
		  <br><br>
               </cfif>

               </cfif>
            </cfif>

         </cfoutput>


<script language="javascript">
$(document).ready(function(){
  jump("start");
});
</script>


   </body>
</html>

