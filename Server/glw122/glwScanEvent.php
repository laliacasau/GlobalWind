<?php header("content-type: text/plain; charset=utf-8"); ?>
<?php
// Mind that some headers are not included because they're either useless or unreliable. X-Secondlife-Local-Position 
$headers    = apache_request_headers();
$objectgrid = $headers["X-Secondlife-Shard"];
$objectname = $headers["X-Secondlife-Object-Name"];
$objectkey  = $headers["X-Secondlife-Object-Key"];
$objectpos  = $headers["X-Secondlife-Local-Position"];
$ownerkey   = $headers["X-Secondlife-Owner-Key"];
$ownername  = $headers["X-Secondlife-Owner-Name"];
$regiondata = $headers["X-Secondlife-Region"];
$regiontmp  = explode ("(",$regiondata);            // cut cords off
$regionname = substr($regiontmp[0],0,-1);           // cut last space from simname
$regiontmp  = explode (")",$regiontmp[1]);
$regionpos  = $regiontmp[0];

$data       = file_get_contents("php://input");
$cols       = explode(",",$data);
require '../../glwdb.php';

$idEvents=(integer)$cols[0];
if ($idEvents == 0) {
    die("KOError id of event");
}


//set ifScan=1 all boats event
$sql="UPDATE glwBoats SET ifScan=1 WHERE idEvents=".$idEvents;
if($conn->query($sql)) {
}else{
    die("KOError reset scan: " . $sql . "\n" . $conn->error);
}

//call polling function
$return="KOpolling not started";
$data2Send="";
$pollMode=2; //info boats
$pollclave="glwScaData"; //key info boats
$response="";

function fcallback($pdata,$pconn){
    if(substr($pdata,0,2)=="OK"){
        $data=explode(",",$pdata);
        $idBoat=$data[1];
        $sql="UPDATE glwBoats SET boatSimName='$data[2]',boatSimX=$data[3],boatSimY=$data[4],
        boatX=$data[5],boatY=$data[6],ifScan=2,info='$data[7],$data[8],$data[9]' WHERE id=$idBoat";
        $pconn->query($sql);
    }
}

//need $idEvents, $data2Send, $pollMode
//return $pollreturn
require 'glwPollBoats.php';
//callback function for each boat OK

//result polling function
if(isset($pollreturn)){
    $return=$pollreturn;
}

if(substr($return,0,2)!="OK"){
    $conn->close();
    die($return);
}
echo $return;

$sql="SELECT ownerName,boatSimName,boatX,boatY,ifScan,info FROM glwBoats WHERE idEvents=$idEvents ORDER BY ownerName";
if($result=$conn->query($sql)){
    if ($result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            if($row["ifScan"]==2) echo ",".$row["ownerName"].",".$row["boatSimName"].",".$row["boatX"].",".$row["boatY"].",".$row["info"];
            else echo ",".$row["ownerName"].",,,,,,";
        }
    }else{
        echo ",No results";
    }
        
}else{
    die("KOError list boats: " . $sql . "\n" . $conn->error);
}


//echo "A";
//echo $return;
$conn->close();
?>


























