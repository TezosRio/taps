<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>

<cfset reload = true>

<cfset totalPoolers = 0>

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

      <script language="javascript">
         var totalPoolers = 0;
      </script>

      <script src="js/jquery-3.2.1.min.js"></script>
      <script src="js/jquery.maskMoney.min.js"></script>

      <script language="javascript">

        function checkFields()
        {
            var address = $("#id_address").val();
            var amount = $("#id_amount").val();
            var fee = $("#id_fee").val();
            var name = $("#id_name").val();

           if (address.length == 0)
           {
              alert('Address field is mandatory!');
              return false;
           }


           var prefix = address.substring(0,2).toLowerCase();

           if ( (prefix != 'tz') && (prefix != 'kt') )
           {
              alert('Addresses must begin with TZ or KT!');
              return false;
           }

           if (address.length < 30)
           {
              alert('Address length seems invalid!');
              return false;
           }


           if (amount.length == 0)
           {
              alert('Amount field is mandatory!');
              return false;
           }

           if (fee.length == 0)
           {
              alert('Fee field is mandatory!');
              return false;
           }

           if (name.length == 0)
           {
              alert('Name field is mandatory!');
              return false;
           }

           return true;

        }

        function saveBondPoolSettings()
        {
           var bp_status;

           bp_status = document.getElementById('id_bondpool_status').checked;

           // Calls Coldfusion method to update local database.
           $.get('bp_proxy.cfm?status=' + bp_status);

        }

        // Delete for dynamic created elements.
        function dynamicDelete()
        {
           var address = $("#_address").val();
           var amount = $("#_amount").val();
           var fee = $("#_fee").val();
           var name = $("#_name").val();
           var isManager = $("#_isManager").val();

           var record = $("#_record").val();
           var reference = document.getElementById('myReference' + record);

           if (confirm('Are you sure to delete record with name ' + name  + '?'))
           {
              $(reference).parents("tr").remove();
              // Calls Coldfusion method to update local database.
              $.get('bp_proxy.cfm?address=' + address + '&amount=' + amount + '&name=' + name + '&fee=' + fee + '&ismanager=' + isManager + '&operation=delete',
                  function(data, status)
                  {
                      if (data.trim() == 'true')
                      {
                         alert("Deleted successfully!");
                      }
                      else
                      {
                         alert("Error - could not delete");
                      }
                  });
           }
        }

        function dynamicUpdate()
        {
           var address = $("#_address").val();
           var amount = $("#_amount").val();
           var fee = $("#_fee").val();
           var name = $("#_name").val();
           var isManager = $("#_isManager").val();

           // Calls Coldfusion method to update local database.
           $.get('bp_proxy.cfm?address=' + address + '&amount=' + amount + '&name=' + name + '&fee=' + fee + '&ismanager=' + isManager + '&operation=update',
                  function(data, status)
                  {
                      if (data.trim() == 'true')
                      {
                         alert("Updated successfully!");
                      }
                      else
                      {
                         alert("Error - could not update");
                      }
                  });

           // Clear fields.
           document.getElementById('id_address').value='';
           document.getElementById('id_amount').value='';
           document.getElementById('id_name').value='';
           document.getElementById('id_manager').checked='false';
           document.getElementById('id_manager').value='false';
           document.getElementById('id_fee').value='';

        }

        $(document).ready(function(){

        $("#id_amount").maskMoney({
         prefix: "",
         decimal: ".",
         thousands: ","
        });

        $("#id_fee").maskMoney({
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

            if (!checkFields())
            { return false; }

            var address = $("#id_address").val();
            var amount = $("#id_amount").val();
            var fee = $("#id_fee").val();
            var name = $("#id_name").val();
            var isManager = $("#id_manager").prop("checked");

            var divNoMembers = document.getElementById('id_nomembers');
            $(divNoMembers).parents("tr").remove();  

            totalPoolers++;
            var i = totalPoolers;

            var markup = '  <tr>' +
                         '     <td align="left">' +
                         '        <input name="address_' + i + '" id="address' + i + '" value="' + address +'" type="text" readonly style="border:none;background:none;width:325px;">' +
                         '     </td>' +
                         '     <td align="center" >' +
                         '        <input name="name_amount' + i + '" id="amount' + i + '" value="' + amount + '" type="text" style="text-align:right;width:110px;" class="name_amount">' +
                         '     </td>' +
                         '     <td align="center" >' +
                         '        <input name="fee' + i + '" id="fee' + i + '" value="' + fee + '" type="text" style="text-align:right;width:50px;">' +
                         '     </td>' +
                         '     <td align="center" >' +
                         '        <input name="names_' + i + '" id="name' + i + '" value="' + name + '" type="text" style="width:100px;">' +
                         '     </td>' +
                         '     <td align="center" >';
                         if (isManager)
                         {
                             markup = markup + '   <input name="ismanager" id="ismanager' + i + '" type="radio" checked>';
                         }
                         else
                         {
                             markup = markup + '   <input name="ismanager" id="ismanager' + i + '" type="radio">';
                         }
                         markup = markup + '     </td>' +
                         '     <td align="center">' +
                         '        <image src="imgs/save.png" title="Update" style="cursor:pointer;"  onClick="document.getElementById(\'id_record\').checked=true;document.getElementById(\'_address\').value=document.getElementById(\'address' + i + '\').value;document.getElementById(\'_amount\').value=document.getElementById(\'amount' + i + '\').value;document.getElementById(\'_name\').value=document.getElementById(\'name' + i + '\').value;document.getElementById(\'_fee\').value=document.getElementById(\'fee' + i + '\').value;document.getElementById(\'_isManager\').value=document.getElementById(\'ismanager' + i + '\').value;document.getElementById(\'_record\').value=' + i + ';dynamicUpdate();" />' +
                         '     </td>' +
                         '     <td align="center" id="myReference' + i + '" >' +
                         '        <image src="imgs/delete.png" id="idDelete' + i + '" title="Delete" style="cursor:pointer;width:30px;height:30px;" onclick="document.getElementById(\'id_record\').checked=true;document.getElementById(\'_address\').value=document.getElementById(\'address' + i + '\').value;document.getElementById(\'_amount\').value=document.getElementById(\'amount' + i + '\').value;document.getElementById(\'_name\').value=document.getElementById(\'name' + i + '\').value;document.getElementById(\'_record\').value=\'' + i + '\';dynamicDelete();">' +
                         '        <input type="checkbox" name="record" id="id_record" style="visibility:hidden;">' +
                         '     </td>' +
                         '     <td style="align:left;width:20px;color:green;visibility:hidden;"></td>' +
                         '  </tr> '; 


            $("table tbody").append(markup);

            $('table').attr('height', 100);

            $("#amount" + i).maskMoney({
             prefix: "",
             decimal: ".",
             thousands: ","
            });

            $("#fee" + i).maskMoney({
             prefix: "",
             decimal: ".",
             thousands: ","
            });

            // Calls Coldfusion method to save to local database.
            $.get('bp_proxy.cfm?address=' + address + '&amount=' + amount + '&name=' + name + '&fee=' + fee + '&ismanager=' + isManager + '&operation=add');

            // Clear fields.
            document.getElementById('id_address').value='';
            document.getElementById('id_amount').value='';
            document.getElementById('id_name').value='';
            //document.getElementById('id_manager').checked='false';
            //document.getElementById('id_manager').value='false';
            document.getElementById('id_fee').value='';

            $("#id_address").focus();
        });

        $(".update-row").click(function(){
            var address = $("#_address").val();
            var amount = $("#_amount").val();
            var fee = $("#_fee").val();
            var name = $("#_name").val();
            var isManager = $("#_isManager").val();

            // Calls Coldfusion method to update local database.
            $.get('bp_proxy.cfm?address=' + address + '&amount=' + amount + '&name=' + name + '&fee=' + fee + '&ismanager=' + isManager + '&operation=update',
                  function(data, status)
                  {
                      if (data.trim() == 'true')
                      {
                         alert("Updated successfully!");
                      }
                      else
                      {
                         alert("Error - could not update");
                      }
                  });



            // Clear fields.
            document.getElementById('id_address').value='';
            document.getElementById('id_amount').value='';
            document.getElementById('id_name').value='';
            document.getElementById('id_manager').checked=false;
            document.getElementById('id_manager').value='false';
            document.getElementById('id_fee').value='';
        });


        // Find and remove selected table rows
        $(".delete-row").click(function(){
            $("table tbody").find('input[name="record"]').each(function(){
            	if($(this).is(":checked")){
                   var address = $("#_address").val();
                   var amount = $("#_amount").val();
                   var fee = $("#_fee").val();
                   var name = $("#_name").val();
                   var isManager = $("#_isManager").val();

                   var record = $("#_record").val();
                   var reference = document.getElementById('myReference' + record);

                    if (confirm('Are you sure to delete record with name ' + name  + '?'))
                    {

                      $(reference).parents("tr").remove();
                      // Calls Coldfusion method to update local database.
                      $.get('bp_proxy.cfm?address=' + address + '&amount=' + amount + '&name=' + name + '&fee=' + fee + '&ismanager=' + isManager + '&operation=delete',
                        function(data, status)
                        {
                            if (data.trim() == 'true')
                            {
                               alert("Deleted successfully!");
                            }
                            else
                            {
                               alert("Error - could not delete");
                            }
                        });
                    }

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

         <!--- Check if all data were fetched --->
         <!--- Get settings --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

         <cfif #settings.recordCount# GT 0>
           <cfif #settings.mode# NEQ "off">
            <cfif #settings.status# EQ true>

               <!--- Get baker's bond pool members ---> 

               <cfinvoke component="components.database" method="getBondPoolMembers" returnVariable="members">
               <cfset totalPoolers = #members.recordcount#>
               <script language="javascript">
                  totalPoolers = #totalPoolers#;
               </script>

               <cfset reload = false>

               <!--- Get bondPool settings --->
               <cfinvoke component="components.database" method="getBondPoolSettings" returnVariable="bondPoolSettings">

               <cfform name="form" action="bondpool.cfm" method="post">
                  <br>
                  <cfinput type="checkbox" id="id_bondpool_status" name="bondpool" checked="#bondPoolSettings.status#" onClick="saveBondPoolSettings();">
                  <label for="id_bondpool_status">Do bond pool payments every cycle</label>

                  <br><br>
                  At each cycle change, Tezos blockchain will deliver rewards to the baker.
                  Part of the rewards is for delegators payment, proportional to their shares.
                  The remaining rewards after delegators payments are for the baker.
                  If the baker have a bond pool, with some participants, this feature can be used
                  to automate bond poolers payments. If activated, this feature will distribute
                  these remaining rewards to bond poolers at each cycle, according to their shares.
                  It is possible to assign one of the members of the pool as manager. And set an
                  administrative fee to be charged from each member. The manager will receive
                  his share of the rewards, plus the administrative fee total sum. If this feature
                  is set to off, then no bondpool rewards distribution will be done.
                  <br><br>

                  Add/update/remove members.<br><br>
                  <input type="text" id="id_address" placeholder="Address" style="text-align:left;width:340px;">
                  <input type="text" id="id_amount" placeholder="Amount (XTZ)" style="text-align:left;width:120px;">
                  <input type="text" id="id_fee" placeholder="Fee" size="5" style="text-align:left;width:80px;">
                  <input type="text" id="id_name" placeholder="Name" style="text-align:left;width:170px;">
                  <input type="checkbox" id="id_manager" value="false"> Is manager?
                  <input type="button" class="add-row" value="ADD">

                  <br><br>   

                  <table class="table table-taps-fees" id="id_members">
                        <thead class="head-table-taps">
                        <tr>
                           <th style="text-align:left;" scope="col">Address</th>
                           <th style="text-align:center;" scope="col">Amount (XTZ)</th>
                           <th style="text-align:left;" scope="col">Fee (%)</th>
                           <th style="text-align:left;" scope="col">Name</th>
                           <th style="text-align:center;" scope="col">Is Manager?</th>
                           <th style="text-align:center;" scope="col"></th>
                           <th style="text-align:center;" scope="col"></th>
                           <th style="text-align:center;" scope="col"></th>
                           <th style="text-align:center;" scope="col"></th>
                        </tr>
                     </thead>

                     <tbody class="members_class" id="idMembers">
                        <cfif #members.recordCount# EQ 0>
                           <tr style="line-height:80px;font-size:18px;"><td colspan="6" id="id_nomembers"><center>There are no bond pool members registered yet.</center></td></tr>
                        </cfif>

                        <cfloop from="1" to="#members.recordCount#" index="i"> 
                           <tr>
                              <td align="left">
                                 <cfinput name="address_#i#" id="address#i#" value="#members.address[i]#" type="text" readonly style="border:none;background:none;width:325px;">
                              </td>

                              <td align="center" >
                                 <cfinput name="name_amount#i#" id="amount#i#" value="#members.amount[i]#" type="text" style="text-align:right;width:110px;" class="name_amount">
                              </td>

                              <td align="center" >
                                 <cfinput name="fee#i#" id="fee#i#" value="#members.adm_charge[i]#" type="text" style="text-align:right;width:50px;">
                              </td>

                              <td align="center">
                                 <cfinput name="names_#i#" id="name#i#" value="#members.name[i]#" type="text" style="width:100px;">
                              </td>

                              <td align="center">
                                 <cfif #members.is_manager[i]# EQ true>
                                    <cfinput name="ismanager" id="ismanager#i#" value="#members.is_manager[i]#" type="radio" checked>
                                 <cfelse>
                                    <cfinput name="ismanager" id="ismanager#i#" value="#members.is_manager[i]#" type="radio">
                                 </cfif>
                              </td>

                              <td align="center">
                                 <image src="imgs/save.png" title="Update" style="cursor:pointer;"  onClick="document.getElementById('id_record').checked=true;document.getElementById('_address').value=document.getElementById('address#i#').value;document.getElementById('_amount').value=document.getElementById('amount#i#').value;document.getElementById('_name').value=document.getElementById('name#i#').value;document.getElementById('_fee').value=document.getElementById('fee#i#').value;document.getElementById('_isManager').value=document.getElementById('ismanager#i#').checked;document.getElementById('_record').value='#i#';" class="update-row" />
                              </td>

                              <td align="center" id="myReference#i#" >
                                 <image src="imgs/delete.png" title="Delete" style="cursor:pointer;width:30px;height:30px;" onClick="document.getElementById('id_record').checked=true;document.getElementById('_address').value=document.getElementById('address#i#').value;document.getElementById('_amount').value=document.getElementById('amount#i#').value;document.getElementById('_name').value=document.getElementById('name#i#').value;document.getElementById('_record').value='#i#';" class="delete-row" />
                                 <input type="checkbox" name="record" id="id_record" style="visibility:hidden;">
                              </td>
                           </tr>
                        </cfloop>

                        <cfinput name="myAddress" id="_address" type="hidden" value="">
                        <cfinput name="myAmount" id="_amount" type="hidden" value="">
                        <cfinput name="myName" id="_name" type="hidden" value="">
                        <cfinput name="myFee" id="_fee" type="hidden" value="">
                        <cfinput name="myIsManager" id="_isManager" type="hidden" value="">
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

</body>
</html>
