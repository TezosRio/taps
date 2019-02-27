<!---

   Name        : barcode.cfc
   Author      : Luiz Milfont
   Notes       : Based on ZXing (Zebra Crossing) library.
   Date        : 02/25/2019
   Description : Barcode generation features.
   
--->

<cfcomponent name="barcode">

   <cffunction name="buildQRCode" returntype="string">
      <cfargument name="text" type="string" required="yes" default="">

      <cfset var result = false>
      <cfset var base64String = "">

      <!--- Use Open Source ZXING libraries --->
      <cfset libraries = [ expandPath('./lib/zxing_core.jar'),expandPath('./lib/zxing_javase.jar') ]>
      <cfset libraryList = ArrayToList(libraries)>
   
      <cftry>
         <cfset origText = "#trim(arguments.text)#" />
	
         <!--- Initialize object and create a new QRCode matrix --->
	 <cfset BarcodeFormat = createObject('java','com.google.zxing.BarcodeFormat', '#libraryList#')>
	 <cfset oBarCode = createObject('java','com.google.zxing.qrcode.QRCodeWriter', '#libraryList#').init()>
         <!--- Define size (150x150) and format of QRCode --->
         <cfset bitMatrix = oBarCode.encode( origText, BarcodeFormat.QR_CODE, 150, 150 )>
         <!--- Render the matrix as a stored buffer image --->
         <cfset converter = createObject('java','com.google.zxing.client.j2se.MatrixToImageWriter', '#libraryList#')>
         <cfset buffer = converter.toBufferedImage( bitMatrix ) />
         <!--- Convert the buffered data into a Coldfusion compatible image --->
         <cfset img = ImageNew( buffer ) />
         <cfimage source="#img#" action="write" destination="#expandPath('./')#imgs/wallet_qr_code.png" overwrite="yes">
         <cfset result = "wallet_qr_code.png">

      <cfcatch type="any">
         <cfset result = "">
      </cfcatch>
      </cftry>

      <cfreturn result>

    </cffunction>

</cfcomponent>


