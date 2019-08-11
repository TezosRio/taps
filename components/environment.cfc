<cfcomponent output="no" displayname="environment">
<cfprocessingdirective pageencoding = "UTF-8" />

<cffunction name="createTables" access="remote"
            hint="Creates needed tables on database" returntype="boolean">

   <cfset var result = true>
   <cftry>
      <!--- Create table to store configuration ---> 
      <cfquery name="createTableSettings" datasource="ds_taps">
	CREATE TABLE settings
	(
           baker_id          VARCHAR(50) NOT NULL,
           default_fee       DECIMAL(6,2) NOT NULL,
           update_freq       INTEGER NOT NULL,
           user_name         VARCHAR(100),
           pass_hash         VARCHAR(150),
           application_port  INTEGER NOT NULL,
           client_path       VARCHAR(200) NOT NULL,
           node_alias        VARCHAR(100) NOT NULL,
           status            BOOLEAN,
           mode              VARCHAR(20),
           hash_salt         VARCHAR(150),
           base_dir          VARCHAR(200) NOT NULL,
           wallet_hash       VARCHAR(150),
           wallet_salt       VARCHAR(150),
           phrase            VARCHAR(150),
           app_phrase        VARCHAR(150),
           funds_origin      VARCHAR(20)
	);
        ALTER TABLE settings ADD PRIMARY KEY (baker_id);
      </cfquery>	
   <cfcatch type="any">
      <cfset result = false>
   </cfcatch>
   </cftry>

   <cftry>
      <!--- Create table to control payments ---> 
      <cfquery name="createTablePayments" datasource="ds_taps">
	CREATE TABLE payments
	(
           baker_id VARCHAR(50) NOT NULL,
           cycle    INTEGER NOT NULL,
           date     DATE,
           result   VARCHAR(20) NOT NULL,
           total    DECIMAL(20,2) NOT NULL
	);
        ALTER TABLE payments ADD PRIMARY KEY (baker_id, cycle, date, result);
      </cfquery>	
   <cfcatch type="any">
      <cfset result = false>
   </cfcatch>
   </cftry>

   <cftry>
      <!--- Create table to control delegators payments ---> 
      <cfquery name="createTableDelegatorsPayments" datasource="ds_taps">
	CREATE TABLE delegatorsPayments
	(
           baker_id VARCHAR(50) NOT NULL,
           cycle    INTEGER NOT NULL,
           address  VARCHAR(50) NOT NULL,
           date     DATE,
           result   VARCHAR(20) NOT NULL,
           total    DECIMAL(20,2) NOT NULL
	);
        ALTER TABLE delegatorsPayments ADD PRIMARY KEY (baker_id, cycle, address, date, result);
      </cfquery>	
   <cfcatch type="any">
      <cfset result = false>
   </cfcatch>
   </cftry>

   <cftry>
      <!--- Create table to control delegators fees ---> 
      <cfquery name="createTableDelegatorsFee" datasource="ds_taps">
	CREATE TABLE delegatorsFee
	(
           baker_id VARCHAR(50)  NOT NULL,
           address  VARCHAR(50)  NOT NULL,
           fee      DECIMAL(6,2) NOT NULL
	);
        ALTER TABLE delegatorsFee ADD PRIMARY KEY (baker_id, address);
      </cfquery>	
   <cfcatch type="any">
      <cfset result = false>
   </cfcatch>
   </cftry>

   <cftry>
      <!--- Create table to control bondpool>
      <cfquery name="createTableBondPool" datasource="ds_taps">
      	   --CREATE TABLE bondPool
	  -- (
         --     baker_id VARCHAR(50)  NOT NULL,
         --     address  VARCHAR(50)  NOT NULL,
         --     amount   DECIMAL(20,2) NOT NULL,
         --     name     VARCHAR(50)
	 --  );
         --  ALTER TABLE bondPool ADD PRIMARY KEY (baker_id, address);
      </cfquery --->	
   <cfcatch type="any">
      <cfset result = false>
   </cfcatch>
   </cftry>

   <cfreturn result>		
</cffunction>

</cfcomponent>

