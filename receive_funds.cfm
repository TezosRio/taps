<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>

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

   </head>

   <body>
      <section class="box-content-rewards">
      <div  style="width:550px;">
         <cfoutput>

         <h1 class="title-baker">
           Wallet
         </h1>
         <h4>Receive funds</h4>

         <!--- Check if there is a saved configuration --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

         <cfif #settings.recordCount# GT 0>

         QR Code image of your address<br>
         <br>

         <!--- Generate QRCode image of the native wallet address --->
         <cfinvoke component="components.barcode" method="buildQRCode" text="#session.myWallet.getPublicKeyHash()#" returnVariable="myQrCode">
         
         <!--- Show the image --->
         <img src="./imgs/#myQrCode#">
 
         <br><br><br>
         &nbsp;&nbsp;&nbsp;

         <button type="button" class="botao-taps" onClick="javascript: window.history.back();">OK</button>

         <cfelse>
            <br>
            There is no configuration saved on settings.<br>
            Please go to SETUP first.<br>
         </cfif>

      </cfoutput>
   </div>
</section>
</body>
</html>
