<%@ Page Title="" Language="C#" MasterPageFile="~/FieldServicesDisplayMaster.Master" AutoEventWireup="true" CodeBehind="Houston.aspx.cs" Inherits="FieldServicesDisplay.Houston" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

   <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    <script type="text/javascript">

        var map; //map variable used throughout the project
        var infoWindow; //infoWindow variable  

        //OverlappingMarkerSpiderfier
        var oms;

        //array to hold client markers
        var clientArrMarkers = [];     

        //variables to store datatables in javascript
        <%--var clientAddresses = JSON.parse('<%= getClientAddresses() %>'); --%>
        <%--var clientGeocodesTwo = JSON.parse('<%= getClientAddressesCopy() %>');--%>
        var activeClients = JSON.parse('<%= getActiveClients() %>');         
        
        //Default Map Settings
        var zoom = 10;
        var center = new google.maps.LatLng(29.753369, -95.363068); //Static center of where all markers can be shown
        cnsltMapOptions = {//Settings for map
            center: center,
            zoom: zoom,
            mapTypeId: google.maps.MapTypeId.HYBRID,
            mapTypeControl: true,
            mapTypeControlOptions: {
                style: google.maps.MapTypeControlStyle.DROPDOWN_MENU,
                position: google.maps.ControlPosition.RIGHT_BOTTOM,
                index: 3
            },
        };

        
        var clHtml;//html string for client infoWindow
        //var button; //variable to store Show/clear All button

        var clientIcon;//marker icon for client
        var latLng;//used to store coords
        var listBoxCount;//hold count for items in listbox
        var searchBox;
        var houBtn;

        //Main function that loads the map, controls and settings
        function load() {                    
            
            //Create map
            map = new google.maps.Map(document.getElementById("map"), cnsltMapOptions); //End Map Variable

            //Load Images and add them to imageArray
            tileNEX = new google.maps.ImageMapType({
                getTileUrl: function(tile, zoom) {
                    return "http://mesonet.agron.iastate.edu/cache/tile.py/1.0.0/nexrad-n0q-900913/" + zoom + "/" + tile.x + "/" + tile.y +".png?"+ (new Date()).getTime(); 
                },
                tileSize: new google.maps.Size(256, 256),
                opacity:0.00,
                name : 'NEXRAD',
                isPng: true,
            });
            map.overlayMapTypes.push(tileNEX);

            tileNEX5 = new google.maps.ImageMapType({
                getTileUrl: function(tile, zoom) {
                    return "http://mesonet.agron.iastate.edu/cache/tile.py/1.0.0/nexrad-n0q-900913-m05m/" + zoom + "/" + tile.x + "/" + tile.y +".png?"+ (new Date()).getTime(); 
                },
                tileSize: new google.maps.Size(256, 256),
                opacity:0.00,
                name : 'NEXRAD5',
                isPng: true,
            });
            map.overlayMapTypes.push(tileNEX5);

            tileNEX10 = new google.maps.ImageMapType({
                getTileUrl: function(tile, zoom) {
                    return "http://mesonet.agron.iastate.edu/cache/tile.py/1.0.0/nexrad-n0q-900913-m10m/" + zoom + "/" + tile.x + "/" + tile.y +".png?"+ (new Date()).getTime(); 
                },
                tileSize: new google.maps.Size(256, 256),
                opacity:0.00,
                name : 'NEXRAD10',
                isPng: true,
                optimized: false
            });
            map.overlayMapTypes.push(tileNEX10);

            tileNEX15 = new google.maps.ImageMapType({
                getTileUrl: function(tile, zoom) {
                    return "http://mesonet.agron.iastate.edu/cache/tile.py/1.0.0/nexrad-n0q-900913-m15m/" + zoom + "/" + tile.x + "/" + tile.y +".png?"+ (new Date()).getTime(); 
                },
                tileSize: new google.maps.Size(256, 256),
                opacity:0.00,
                name : 'NEXRAD15',
                isPng: true,
            });
            map.overlayMapTypes.push(tileNEX15);

            tileNEX20 = new google.maps.ImageMapType({
                getTileUrl: function(tile, zoom) {
                    return "http://mesonet.agron.iastate.edu/cache/tile.py/1.0.0/nexrad-n0q-900913-m20m/" + zoom + "/" + tile.x + "/" + tile.y +".png?"+ (new Date()).getTime(); 
                },
                tileSize: new google.maps.Size(256, 256),
                opacity:0.00,
                name : 'NEXRAD20',
                isPng: true,
            });
            map.overlayMapTypes.push(tileNEX20);

            tileNEX25 = new google.maps.ImageMapType({
                getTileUrl: function(tile, zoom) {
                    return "http://mesonet.agron.iastate.edu/cache/tile.py/1.0.0/nexrad-n0q-900913-m25m/" + zoom + "/" + tile.x + "/" + tile.y +".png?"+ (new Date()).getTime(); 
                },
                tileSize: new google.maps.Size(256, 256),
                opacity:0.00,
                name : 'NEXRAD25',
                isPng: true,
            });
            map.overlayMapTypes.push(tileNEX25);

            tileNEX30 = new google.maps.ImageMapType({
                getTileUrl: function(tile, zoom) {
                    return "http://mesonet.agron.iastate.edu/cache/tile.py/1.0.0/nexrad-n0q-900913-m30m/" + zoom + "/" + tile.x + "/" + tile.y +".png?"+ (new Date()).getTime(); 
                },
                tileSize: new google.maps.Size(256, 256),
                opacity:0.00,
                name : 'NEXRAD30',
                isPng: true,
            });
            map.overlayMapTypes.push(tileNEX30);

            animateRadar();

            infoWindow = new google.maps.InfoWindow; //InfoWindow object

            oms = new OverlappingMarkerSpiderfier(map);

            //Closes current InfoWidnow when clicked on map
            google.maps.event.addListener(map, "click", function () {
                infoWindow.close();
            });

            oms.addListener('spiderfy', function(markers) {
                infoWindow.close();
            });

            var input = document.getElementById('pac-input');
            searchBox = new google.maps.places.SearchBox(input);
            //map.controls[google.maps.ControlPosition.BOTTOM_LEFT].push(input);

            map.addListener('bounds_changed', function(){
                searchBox.setBounds(map.getBounds());
            });
            
            var searchMarkers = [];

            searchBox.addListener('places_changed', function(){
                var places = searchBox.getPlaces();

                if(places.length == 0){
                    return;
                }

                var bounds = new google.maps.LatLngBounds();
                places.forEach(function(place){
                    var searchIcon = {
                        url: place.icon,
                        size: new google.maps.Size(71, 71),
                        origin: new google.maps.Point(0, 0),
                        anchor: new google.maps.Point(17, 34),
                        scaledSize: new google.maps.Size(25, 25)
                    };

                    searchMarkers.push(new google.maps.Marker({
                        map: map,
                        icon: searchIcon,
                        title: place.name,
                        position: place.geometry.location
                    }));

                    if (place.geometry.viewport)
                    {
                        bounds.union(place.geometry.viewport);
                    }else {
                        bounds.extend(place.geometry.location);
                    }
                });
                map.fitBounds(bounds);
            });
        

            //--------------------CLIENTS--------------------------------------------------------------------                   

            //COUNTS
            var acCount = <%= clntsCount %>;//getActiveClients Count
            var gccount = <%= gcCount %>; //getClientAddresses Count
            var schdlCount = <%= schdlCount %>;//getTodaysSchedule Count                     
            listBoxCount = <%= addrBoxCount %>;//bindClientAddrListBox Count
            //var copycount = <%= copyCount %>;//getClientAddressesCopy Count   
            

            //create icon to display green pin as marker
            //clientIcon = new google.maps.MarkerImage('Images/clientpin-small-GREEN.png',
            //                new google.maps.Size(40, 40),
            //                new google.maps.Point(0, 0),
            //                new google.maps.Point(19, 39)
            //                );
            
            //----DISPLAY CLIENT MARKERS-----------------------------------------

            for (var clIndx = 0; clIndx < acCount; clIndx++) //for rows upto 250 in latlng table
            {                
                ////////////---ALL CLIENTS---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //var clData = clientAddresses[clIndx]; //store array of latlngs for addresses
                //var clAddress = clientAddresses[clIndx].cmpAddr; 
                //clHtml = "<b>" + clientAddresses[clIndx].cmpName + "</b> <br />" + clAddress + "<br /> " + clientAddresses[clIndx].cmpAddrRecId; //html to display in infoWindow

                ////////////---ACTIVE CLIENTS---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                var clData = activeClients[clIndx]; //store array of latlngs for addresses
                var acAddress = activeClients[clIndx].addr1 + ", " + activeClients[clIndx].addr2 + ", " + activeClients[clIndx].city + ", " + activeClients[clIndx].stateId + " " + activeClients[clIndx].zip; 
                clHtml = "<b>" + activeClients[clIndx].cmpName + "</b> <br />" + acAddress + "<br /> " + activeClients[clIndx].cmpAddrRecId; //html to display in infoWindow

                //while the lat and lng columns are not null
                if (clData.llLat !== null && clData.llLng !== null){
                    latLng = new google.maps.LatLng(clData.llLat, clData.llLng); 
                     
                    switch (activeClients[clIndx].ownerLevel){
                        //HOUSTON-------------------------------------------------------------------------------------------
                        case 2:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-GREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break; 
                        case 47:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-GREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;                          
                        case 60:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-GREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                        case 61:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-GREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                        case 69:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-GREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                                      
                            //CORPORATE----------------------------------------------------------------------------------------
                        case 38:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-TEAL.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //DALLAS------------------------------------------------------------------------------------------
                        case 46:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-BLUE.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                        case 70:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-BLUE.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break; 
                            //DUBAI-------------------------------------------------------------------------------------------
                        case 52:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-GOLD.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //AUSTIN--------------------------------------------------------------------------------------------
                        case 55:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-ORANGE.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //SAN ANTONIO--------------------------------------------------------------------------------------------
                        case 63:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-YELLOW.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //WOODLANDS--------------------------------------------------------------------------------------------
                        case 64:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-DARKGREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                        case 67:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-DARKGREEN.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //MIDLAND--------------------------------------------------------------------------------------------
                        case 66:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-PURPLE.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //NEW JERSEY--------------------------------------------------------------------------------------------
                        case 71:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-RED.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                        case 74:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-RED.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                        case 75:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-RED.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //NEW YORK--------------------------------------------------------------------------------------------
                        case 72:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-PINK.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //NORTH EAST--------------------------------------------------------------------------------------------
                        case 73:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-LIGHTPINK.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                            //AIO--------------------------------------------------------------------------------------------
                        case 76:
                            clientIcon = new google.maps.MarkerImage('Images/clientpin-small-BLACK.png',
                            new google.maps.Size(40, 40),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(19, 39)
                            );
                            break;
                    }      

                    //Create client marker
                    var clientMarker = new google.maps.Marker({
                        map: map,
                        position: latLng,
                        title: activeClients[clIndx].cmpName,
                        //title: clientAddresses[clIndx].cmpName,
                        icon: clientIcon
                    });

                    bindInfoWindow(clientMarker, map, infoWindow, clHtml); 

                    //Add displayed markers into array of markers
                    clientArrMarkers.push(clientMarker);//Add displayed markers into array of markers      
                    oms.addMarker(clientMarker);                         

                    //Center the map to show all markers on load
                    //var bounds = new google.maps.LatLngBounds();
                    //for (var k = 0; k < clientArrMarkers.length; k++) {
                    //    bounds.extend(clientArrMarkers[k].getPosition());
                    //}
                }                
            }        
            //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                
            //map.fitBounds(bounds); //Center the map to show all markers on load
            
            //--------------------END CLIENTS--------------------------------------------------------------------
            

            //Resize Function
            google.maps.event.addDomListener(window, "resize", function() {
                var center = map.getCenter();
                google.maps.event.trigger(map, "resize");
                map.setCenter(center);
            });

            google.maps.event.addDomListener(window, 'load', load);


            

        }//END LOAD-------------------------------------------------------------------------------------
         
        function animateRadar() {
            var index = map.overlayMapTypes.getLength() - 1;

            window.setInterval(function(){

                map.overlayMapTypes.getAt(index).setOpacity(0.00);

                index--;
                if(index < 0){
                    index = map.overlayMapTypes.getLength() - 1;
                }
                map.overlayMapTypes.getAt(index).setOpacity(0.60);
            }, 400);
        }

        function showRegion()
        {
            $("button").click(function(){

                switch(this.id){
                    case 'houstonBtn': 
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 2 || activeClients[mrkr].ownerLevel != 47
                                || activeClients[mrkr].ownerLevel != 60 || activeClients[mrkr].ownerLevel != 61
                                || activeClients[mrkr].ownerLevel != 69){
                                clientArrMarkers[mrkr].setVisible(false);                                
                            }            
                            if(activeClients[mrkr].ownerLevel == 2 || activeClients[mrkr].ownerLevel == 47
                                || activeClients[mrkr].ownerLevel == 60 || activeClients[mrkr].ownerLevel == 61
                                || activeClients[mrkr].ownerLevel == 69 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }      
                        }
                        break;
                    case 'corpBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 38){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 38 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'dalBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 46 || activeClients[mrkr].ownerLevel != 70){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 46 || activeClients[mrkr].ownerLevel == 70 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'dubBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 52){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 52 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'ausBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 55){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 55 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'sanBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 63){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 63 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'wdlndsBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 64 || activeClients[mrkr].ownerLevel != 67){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 64 || activeClients[mrkr].ownerLevel == 67 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'mdlndBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 66){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 66 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'njBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 71 || activeClients[mrkr].ownerLevel != 74 || activeClients[mrkr].ownerLevel != 75){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 71 || activeClients[mrkr].ownerLevel == 74 || activeClients[mrkr].ownerLevel == 75 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'nyBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 72){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 72 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'neBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 73){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 73 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'aioBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if (activeClients[mrkr].ownerLevel != 76){
                                clientArrMarkers[mrkr].setVisible(false);
                            }                    
                            if(activeClients[mrkr].ownerLevel == 76 && clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                    case 'allBtn':
                        for(var mrkr = 0; mrkr < clientArrMarkers.length; mrkr++){
                            if(clientArrMarkers[mrkr].getVisible() == false){
                                clientArrMarkers[mrkr].setVisible(true);
                            }
                        }
                        break;
                }

            })

            //var corpBtn = document.getElementById('corpBtn');
            //corpBtn.addEventListener('click', function(){
            //    alert("works"); 
            //    return false;
            //});
        }


        //Settings for InfoWindow 
        function bindInfoWindow(marker, map, infoWindow, html) {
            google.maps.event.addListener(marker, 'click', function () {
                infoWindow.setContent(html);
                infoWindow.open(map, marker);
            });
        }

        //Function to retrieve data from XML (may not need it)
        //function downloadUrl(url, callback) {
        //    var request = window.ActiveXObject ?
        //            new ActiveXObject('Microsoft.XMLHTTP') :
        //            new XMLHttpRequest;
        //    request.onreadystatechange = function () {
        //        if (request.readyState === 4) {
        //            request.onreadystatechange = doNothing;
        //            callback(request, request.status);
        //        }
        //    };
        //    request.open('GET', url, true);
        //    request.send(null);
        //}

        function doNothing() {
        }
    </script>

    <h1 style="text-align: center; margin-bottom: 0; font-size: 36px;">HOUSTON</h1>

    <%--<table style="width: 100%; height: 100%; align-items: center;">--%>
    <div class="container">

        <%--<div id="map" style="width: 1200px; border: solid; border-width: 2px; border-color: black; margin: 2px 50px 5px 50px;">--%>

        <%--<table style="width: 1150px; align-content: center; margin: 0 50px 15px 50px; padding: 0 45px 0 45px;">--%>
        <table class="table">
            <tr>
                <td style="width: 100%;">
                    <div id="map_container">
                        <div id="map"></div>
                    </div>
                </td>
                </tr>
                <%--<tr>
                <td>

                    <table style="padding-top: 16px;"  class="regionbtns">
                        <tr>
                            <td>
                                <button class="btnStyle"  id="houstonBtn" onclick="showRegion();return false;">Houston</button>

                                <button class="btnStyle" id="corpBtn" onclick="showRegion();return false;">Corporate</button>

                                <button class="btnStyle" id="dalBtn" onclick="showRegion();return false;">Dallas</button>
                            
                                <button class="btnStyle" id="dubBtn" onclick="showRegion();return false;">Dubai</button>

                                <button class="btnStyle" id="ausBtn" onclick="showRegion();return false;">Austin</button>

                                <button class="btnStyle" id="sanBtn" onclick="showRegion();return false;">San Antonio</button>

                                <button class="btnStyle" id="wdlndsBtn" onclick="showRegion();return false;">Woodlands</button>

                                <button class="btnStyle" id="mdlndBtn" onclick="showRegion();return false;">Midland</button>

                                <button class="btnStyle" id="njBtn" onclick="showRegion();return false;">New Jersey</button>      

                                <button class="btnStyle" id="nyBtn" onclick="showRegion();return false;">New York</button>

                                <button class="btnStyle" id="neBtn" onclick="showRegion();return false;">North East</button>

                                <button class="btnStyle" id="aioBtn" onclick="showRegion();return false;">AIO</button>

                                <button class="btnStyle" id="allBtn" onclick="showRegion();return false;">View All</button>
                            </td>
                        </tr>
                    </table>

                </td>
            </tr>--%>
            <tr>
                <td class="searchbar">
                    <input id="pac-input" class="controls" type="text" size="50" placeholder="Search Places" />
                </td>
            </tr>
        </table>
    </div>

</asp:Content>
