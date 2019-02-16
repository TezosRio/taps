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
       <cfset application.tz =  "&##42793;">

       <cfset application.version = "0.8.3">
       <cfset application.bakerId = "">
       <cfset application.fee="">
       <cfset application.freq="">
       <cfset application.militez=1000000>
       <cfset application.port=8888>
       <cfset application.mode_no="0">
       <cfset application.mode_try="1">
       <cfset application.mode_yes="2">
       <cfset application.mode_desc_no="off">
       <cfset application.mode_desc_try="simulation">
       <cfset application.mode_desc_yes="on">
       <cfset application.user = "">

       <!--- If not behind a proxy, leave blank --->
       <cfset application.proxyServer="">
       <cfset application.proxyPort="80">

       <!--- Create needed database tables --->
       <cfinvoke component="components.environment" method="createTables">
        
       <cfreturn true />
    </cffunction>	

	
</cfcomponent>

