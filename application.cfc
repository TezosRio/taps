<!---

   Project : TAPS - Tezos Automatic Payment System
             Created by Tezos.Rio
             01/11/2019
 --->


<cfcomponent displayname="TAPS" output="true">

<!--- Set application configuration --->
<cfset THIS.Name = "TAPS" />
<cfset THIS.SessionTimeout = CreateTimeSpan( 0, 0, 20, 0 ) />
<cfset THIS.SessionManagement = true />
<cfset THIS.ClientManagement = false />
<cfset THIS.LoginStorage = "session" />
<cfset THIS.applicationTimeout = createTimeSpan( 365, 0, 0, 0 ) />
<cfset this.mappings = structNew() />
<cfset this.mappings["/components"] = getDirectoryFromPath(getCurrentTemplatePath()) & "components/" />

<!--- Set default charset to UTF-8 --->
<cfprocessingdirective pageencoding="UTF-8">
<cfcontent type="text/html; charset=UTF-8">
<cfset setEncoding("URL", "UTF-8")>
<cfset setEncoding("Form", "UTF-8")>
<!--- Some configuration constants --->
<cfscript>
   setLocale("English (US)");
</cfscript>


<!--- Define datasource to Lucee H2 database ---> 
<cfscript>
   this.datasources.ds_taps =
   {
      class= "org.h2.Driver",
      connectionString= "jdbc:h2:#expandPath("database/tapsDB")#;MODE=MySQL",
      username: "superadmin",
      password: "spat_drowssap"
   }
</cfscript>
	
<cffunction
        name="OnApplicationStart"
        access="public"
        returntype="boolean"
        output="false">

       <!--- Create some application constants --->
       <!--- Do not change                     --->
       <cfset application.tz = "&##42793;">
       <cfset application.version = "1.2.1">
       <cfset application.militez = 1000000>
       <cfset application.port = #CGI.SERVER_PORT#>
       <cfset application.mode_no = "0">
       <cfset application.mode_try = "1">
       <cfset application.mode_yes = "2">
       <cfset application.mode_desc_no = "off">
       <cfset application.mode_desc_try = "simulation">
       <cfset application.mode_desc_yes = "on">
       <cfset application.TezosJ_SDK_location = "lib/tezosj-sdk-plain-java-1.2.2.jar">
       <cfset application.tezosTransactionHashLength = 51>
       
       <!--- Some application variables initialization --->
       <!--- Do not change                             --->
       <cfset application.bakerId = "">
       <cfset application.fee="">
       <cfset application.freq="">
       <cfset application.user = "">

       <!--- Application variables you may edit --->
       <cfset application.encSeed = "?73205!"> <!--- Used to hash sensible information along the code --->
       <cfset application.proxyServer="">      <!--- Proxy Server if you are behind a proxy/firewall  --->
       <cfset application.proxyPort="80">      <!--- Proxy port if you are behind a proxy/firewall    --->
       <cfset application.provider = "https://tezos-prod.cryptonomic-infra.tech"> <!--- Tezos node to connect to --->
       <cfset application.paymentRetries = 1>  <!--- Number of times Taps will try to pay if it failed in confirming from blockchain --->
       <cfset application.gasLimit = 15400>    <!--- gastLimit for Tezos blockchain operations --->
       <cfset application.storageLimit = 300>  <!--- storageLimit for Tezos blockchain operations ---> 
       <cfset application.numberOfBlocksToWait = 5> <!--- After Taps has sent a tx, how many blocks it checks to see if it was applied --->
       <cfset application.blockExplorer = "https://tezblock.io/transaction/"> <!--- URL of prefered block explorer to check a transaction --->
       <cfset application.minutesBetweenTries = 1> <!--- Number of minutes to wait between each payment try in the loop --->
       <cfset application.tz_default_operation_fee = "0.001800"> <!--- Default fee to be used in transactions --->

       <!--- Create needed database tables --->
       <cfinvoke component="components.environment" method="createTables">
        
       <cfreturn true />
    </cffunction>	

	
</cfcomponent>

