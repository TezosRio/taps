<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>

<cfset reload = true>

<cfset address="">
<cfset saveIt="0">

<cfif #isDefined('form.address')#>
   <cfset address="#form.address#">
</cfif>
<cfif #isDefined('form.saveit')#>
   <cfset saveIt="#form.saveit#">
</cfif>

<cfif #int(saveIt)# EQ "1">
   <!--- Save  --->
   <cfinvoke component="components.database" method="">
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
      <script src="js/jquery.maskMoney.min.js"></script>

      <script language="javascript">
        function sendForm(field)
        {
           document.form.address.value = field.id;
           document.form.saveit.value = '1';
           document.form.submit();
        }

        $(document).ready(function(){


        $("#id_amount").maskMoney({
         prefix: "",
         decimal: ".",
         thousands: ","
        });

        $(".name_amount").maskMoney({
         prefix: "",
         decimal: ".",
         thousands: ","
        });

        $(".add-row").click(function(){
            var address = $("#id_address").val();
            var amount = $("#id_amount").val();
            var name = $("#id_name").val();
            var markup = '<tr>' + 
                         '     <td align="left" size="40">' + address + '</td>' +
                         '     <td align="center" type="text" size="8" style="text-align: right;">' + amount + '</td>' +
                         '     <td align="center" type="text" size="8" style="text-align: left;">' + name + '</td>' +
                         '     <td align="center" type="text">00%</td>' +
                         '  </tr>';
            $("table tbody").append(markup);

            // Calls Coldfusion method to save to local database.
            $.get('bp_proxy.cfm?address=' + address + '&amount=' + amount + '&name=' + name + '&operation=add');

            // Clear fields.
            document.getElementById('id_address').value='';
            document.getElementById('id_amount').value='';
            document.getElementById('id_name').value='';
        });

        $(".update-row").click(function(){
            var address = $("#_address").val();
            var amount = $("#_amount").val();
            var name = $("#_name").val();

            // Calls Coldfusion method to update local database.
            $.get('bp_proxy.cfm?address=' + address + '&amount=' + amount + '&name=' + name + '&operation=update');

            // Clear fields.
            document.getElementById('id_address').value='';
            document.getElementById('id_amount').value='';
            document.getElementById('id_name').value='';
        });

        
        // Find and remove selected table rows
        $(".delete-row").click(function(){
            $("table tbody").find('input[name="record"]').each(function(){
            	if($(this).is(":checked")){
                   var address = $("#_address").val();
                   var amount = $("#_amount").val();
                   var name = $("#_name").val();
                   var record = $("#_record").val();
                   var reference = document.getElementById('myReference' + record);

                   $(reference).parents("tr").remove();
                    // Calls Coldfusion method to delete from local database.
                    $.get('bp_proxy.cfm?address=' + address + '&amount=' + amount + '&name=' + name + '&operation=delete');
                }
            });
        });
        });    

      </script>

   </head>

   <body>
      <section class="box-content-rewards">
         <cfoutput>

         <h1>Bond Pool</h1>
         <h4>Configure your bond pool</h4>
         Add/update/remove members.<br><br>

         <!--- Check if all data were fetched from TzScan --->
         <!--- Get settings --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

         <cfif #settings.recordCount# GT 0>
           <cfif #settings.mode# NEQ "off">
            <cfif #settings.status# EQ true>

               <!--- Get baker's bond pool members ---> 

               <cfinvoke component="components.database" method="getBondPoolMembers" returnVariable="members">
               <cfset reload = false>

               <cfform name="form" action="bondpool.cfm" method="post">

                  <input type="text" id="id_address" placeholder="Address">
                  <input type="text" id="id_amount" placeholder="Amount (XTZ)" style="text-align:right;">
                  <input type="text" id="id_name" placeholder="Name">
                  <input type="button" class="add-row" value="ADD MEMBER">

                  <br><br>   

                  <table class="table table-taps-fees" id="id_members">
                        <thead class="head-table-taps">
                        <tr>
                           <th style="text-align:left;" scope="col">Address</th>
                           <th style="text-align:center;" scope="col">Amount (XTZ)</th>
                           <th style="text-align:left;" scope="col">Name</th>
                           <th style="text-align:center;" scope="col">Share</th>
                           <th style="text-align:center;" scope="col"></th>
                           <th style="text-align:center;" scope="col"></th>
                           <th style="text-align:center;" scope="col"></th>
                        </tr>
                     </thead>

                     <tbody>
                        <cfloop from="1" to="#members.recordCount#" index="i"> 
                           <tr>
                              <td align="left">
                                 <cfinput name="address_#i#" id="address#i#" value="#members.address[i]#" type="text" size="40" readonly style="border:none;background:none;">
                              </td>

                              <td align="center" >
                                 <cfinput name="name_amount#i#" id="amount#i#" value="#members.amount[i]#" type="text"size="8" style="text-align:right;" class="name_amount">
                              </td>

                              <td align="center" >
                                 <cfinput name="names_#i#" id="name#i#" value="#members.name[i]#" type="text" size="8">
                              </td>

                              <td align="center" >
                                 00%
                              </td>

                              <td align="center">
                                 <image src="imgs/save.png" title="Update" style="cursor:pointer;"  onClick="document.getElementById('id_record').checked=true;document.getElementById('_address').value=document.getElementById('address#i#').value;document.getElementById('_amount').value=document.getElementById('amount#i#').value;document.getElementById('_name').value=document.getElementById('name#i#').value;document.getElementById('_record').value='#i#';" class="update-row" />
                              </td>

                              <td align="center" id="myReference#i#" >
                                 <image src="imgs/delete.png" title="Delete" style="cursor:pointer;width:30px;height:30px;" onClick="document.getElementById('id_record').checked=true;document.getElementById('_address').value=document.getElementById('address#i#').value;document.getElementById('_amount').value=document.getElementById('amount#i#').value;document.getElementById('_name').value=document.getElementById('name#i#').value;document.getElementById('_record').value='#i#';" class="delete-row" />
                                 <input type="checkbox" name="record" id="id_record" style="visibility:hidden;">
                              </td>

                              <td style="align:left;width:20px;color:green;visibility:hidden;">Updated</td>
                           </tr>
                        </cfloop>

                        <cfinput name="myAddress" id="_address" type="hidden" value="">
                        <cfinput name="myAmount" id="_amount" type="hidden" value="">
                        <cfinput name="myName" id="_name" type="hidden" value="">
                        <cfinput name="record" id="_record" type="hidden" value="">


                        <cfinput name="saveit" type="hidden" value="0">

                     </tbody>
                  </table>

               </cfform>
                    <br><br><br><br><br><br>
            <cfelse>
               <br><br><br><br><br><br>
               <table width="100%">
                  <tr><td align="center"><img src="imgs/spin.gif" width="50" height="50"><br></td></tr>
                  <tr style="line-height:30px;text-align:center;"><td align="center">Fetching... Please wait</td></tr>
               </table>
            </cfif>

          <cfelse>
             <br>
             TAPS status is set to OFF.<br>
             Please go to menu option STATUS and choose another option.<br>
          </cfif>     

         <cfelse>
            <br>
            There is no configuration saved on settings.<br>
            Please go to SETUP first.<br>
         </cfif>
  
      </cfoutput>
</section>

<cfif #reload# EQ true>
   <!---  Reload page until fetch completed --->
   <script language="javascript">
      setTimeout(function(){ location.reload(); }, 5000);
   </script>
</cfif>

</body>
</html>

