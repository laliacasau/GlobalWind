<?php

function rolling_curl($ppollMode, $purls, $pdata2Send, $pconn, $custom_options = null) {
    $numBoatsOk=0;
    // make sure the rolling window isn't greater than the # of urls
    $rolling_window = 5;
    $rolling_window = (sizeof($purls) < $rolling_window) ? sizeof($purls) : $rolling_window;

    $master = curl_multi_init();
    $curl_arr = array();

    // add additional curl options here
    $std_options = array(CURLOPT_RETURNTRANSFER => true,
    CURLOPT_FOLLOWLOCATION => true,
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => $pdata2Send,   //send data to POST method 
    CURLOPT_TIMEOUT => 10, 
    CURLOPT_MAXREDIRS => 5);
    $options = ($custom_options) ? ($std_options + $custom_options) : $std_options;

    // start the first batch of requests
    for ($i = 0; $i < $rolling_window; $i++) {
        $ch = curl_init();
        $options[CURLOPT_URL] = $purls[$i];
        curl_setopt_array($ch,$options);
        curl_multi_add_handle($master, $ch);
    }
    do {
        while(($execrun = curl_multi_exec($master, $running)) == CURLM_CALL_MULTI_PERFORM);
        if($execrun != CURLM_OK)
            break;
        // a request was just completed -- find out which one
        while($done = curl_multi_info_read($master)) {
            $info = curl_getinfo($done['handle']);
            if ($info['http_code'] == 200)  {
                $output = curl_multi_getcontent($done['handle']);

                // request successful.  process output using the callback function.
                if(substr($output,0,2)=="OK") $numBoatsOk++;
                if($ppollMode==1) fcallback($output,$pconn);   //update
                else if($ppollMode==2) fcallback($output,$pconn);  //scan

                // start a new request (it's important to do this before removing the old one)
                $ch = curl_init();
                $options[CURLOPT_URL] = $purls[$i++];  // increment i
                curl_setopt_array($ch,$options);
                curl_multi_add_handle($master, $ch);

                // remove the curl handle that just completed
                curl_multi_remove_handle($master, $done['handle']);
            } else {
                // request failed.  add error handling.
            }
        }
    } while ($running);
   
    curl_multi_close($master);
    return $numBoatsOk;
}

$pollreturn="";
$pollsw=0;
$totalBoats=0;

if (!isset($conn)){
    $pollreturn="KOError: need set connection";
    $pollsw=1;
}if(!isset($pollMode)){
    $pollreturn="KOError: need polling Mode data";
    $pollsw=1;
}else if(!isset($idEvents)){
    $pollreturn="KOError: need event id";
    $pollsw=1;
}else if(!isset($data2Send)){
    $pollreturn="KOError: need data to send";
    $pollsw=1;
}else if(!isset($pollclave)){
    $pollreturn="KOError: need clave polling";
    $pollsw=1;
}else{
    //find boats url
    $aurls=[];
    if($pollMode==2) $pollsql = "SELECT id,boatUrl FROM glwBoats WHERE idEvents=".$idEvents." && ifScan=1";  //scan
    else if($pollMode==3) $pollsql = "SELECT id,boatUrl FROM glwBoats WHERE idEvents=".$idEvents;  //say
    else $pollsql = "SELECT id,boatUrl FROM glwBoats WHERE idEvents=".$idEvents." && ifModif=1";   //modif event
    $pollresult = $conn->query($pollsql);
    if($pollresult){
        $totalBoats=$pollresult->num_rows;
        if($totalBoats>0){
            foreach($pollresult as $field=>$value){
                //add clave and id boat. This id is return at response
                $aurls[]=$value['boatUrl']."?".$pollclave.",".$value['id'];
            }
        }else{
            $pollreturn="OK,0,".$totalBoats.",There is no active boat ";
            $pollsw=1;
        }
        if(isset($pollUrlExtra)){
            if($pollUrlExtra!=""){
                $aurls[]=$pollUrlExtra."?".$pollclave.",0";
                $pollsw=0;
            }
        }
        if($pollsw==0){
            $boatsok=rolling_curl($pollMode, $aurls, $data2Send, $conn, $custom_options = null);
            $pollreturn="OK,".$boatsok.",".$totalBoats;
        }
    }else {
        $pollreturn="KOSelect Boats Error: " . $sql . "\n" . $conn->error;
        $pollsw=1;
    }
}
?>