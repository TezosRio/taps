<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfset opt="setup">

<cfif #isDefined('url.opt')#>
   <cfset opt="#url.opt#">
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="description" content="Tezos.RIO is team of developers, designers, investors, based on Rio de Janeiro, Brazil. Programming, Baking, Wallets, Tools, Apps, Smart Contracts, Liquidity, Michelson courses and much more.">
    <meta name="author" content="Tezos.Rio - developer">
    <meta name="keywords" content="tezosj_sdk, baking, carteira, tezos, liquidity, michelson">
    <meta name="reply-to" content="contato@tezos.rio">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <meta http-equiv="cache-control" content="no-cache">

    <title>TAPS</title>

    <link rel="shortcut icon" href="imgs/favicon.ico">
    <!-- CSS Bootstrap-->
    <link rel="stylesheet" type="text/css" href="css/bootstrap.min.css"> 
    <!-- CSS Page-->
    <link rel="stylesheet" type="text/css" href="css/estilo.css">

    <script language="javascript">
       function resizeIframe(obj)
       {
          obj.style.height = obj.contentWindow.document.body.scrollHeight + 'px';
       }
    </script>

</head>
<body>

    <div class="wrapper">
        <!-- Sidebar Holder -->
        <nav id="sidebar">
            <div class="sidebar-header" style="margin-top:20px">
 
            <figure>
                <a href="menu.cfm" style="margin-left: 5px"> 
                  <img src="imgs/taps_logo_dourada.png" class="img-logo-taps" alt="TAPS" width="150">
                </a>    
            </figure>
                   
            </div>
            <ul class="list-unstyled components">
                <li>
                    <a href="menu.cfm?opt=wallet" id="item-menu" name="wallet">WALLET</a>
                </li>
                <li>
                    <a href="menu.cfm?opt=setup" id="item-menu" name="setup">SETUP</a>
                </li>
                <li>
                    <a href="menu.cfm?opt=status" id="item-menu" name="status">STATUS</a>
                </li>
                <li>
                    <a href="menu.cfm?opt=security" id="item-menu"  name="secutiry">SECURITY</a>
                </li>
                <li>
                    <a href="menu.cfm?opt=advanced" id="item-menu"  name="fee">ADVANCED</a>
                </li>
                <li>
                    <a href="menu.cfm?opt=bondpool" id="item-menu"  name="secutiry">BOND POOL</a>
                </li>
                <li>
                    <a href="menu.cfm?opt=rewards" id="item-menu"  name="rewards">REWARDS</a>
                </li>
                <li>
                    <a href="menu.cfm?opt=delegators" id="item-menu"  name="delegators">DELEGATORS</a>
                </li>
                <li>
                    <a href="menu.cfm?opt=fees" id="item-menu"  name="fee">FEES</a>
                </li>
                <li>
                    <a href="menu.cfm?opt=payments" id="item-menu" name="payments">PAYMENTS</a>
                </li>
                <li>
                    <a href="menu.cfm?opt=reset" name="reset">RESET</a>
                </li>
                <li>
                   <a href="logout.cfm" target="_self" name="reset">LOGOUT</a>
                </li>
            </ul>


        </nav>

        <section id="content">
                    <button type="button" id="sidebarCollapse" class="navbar-btn">
                        <span></span>
                        <span></span>
                        <span></span>
                    </button>
                            
            <cfoutput><iframe style="margin-top:20px;width:100%;" src="#opt#.cfm" name="iframe" id="idIframeMain" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe></cfoutput>
            <div class="embed-responsive embed-responsive-21by9"></div>

       </section>

<!--Library-->
<script src="js/jquery-3.2.1.min.js"></script>
<script src="js/bootstrap.min.js"></script>
<!-- JS Effects-->
<script type="text/javascript" src="js/efeitos.js"></script>

</body>
</html>
