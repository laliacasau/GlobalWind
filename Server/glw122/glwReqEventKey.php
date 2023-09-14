<?php header("content-type: text/plain; charset=utf-8"); ?>
<?php
//GLW Verify that the event key does not exist

$data = file_get_contents("php://input");
$data = trim($data);

require '../../glwdb.php';

if($data!=""){
    $sql = "SELECT * FROM glwEvents WHERE eventKey='".$data."'";
    $result = $conn->query($sql);
    $numRows=$result->num_rows;
    if ($numRows == 0) {
        $conn->close();
        die("OK1The KEY you entered does not exist");
    } else {
        $row = $result->fetch_assoc();
        $s=$row['directorKey'].",".$row['eventNum'].",".$row['id'].",".$row['server'].",".$row['directorName'].",".
            $row['wndDir'].",".$row['wndSpeed'].",".$row['wndGusts'].",".$row['wndShifts'].",".$row['wndPeriod'].",".
            $row['wavSpeed'].",".$row['wavHeightVariance'].",".$row['wavLengthVariance'].",".$row['wavHeight'].",".
            $row['wavLength'].",".$row['wavEffects'].",".$row['crtDir'].",".$row['crtSpeed'].",".
            $row['sailMode'].",".$row['eventName'].",".$row['extra1'].",".$row['extra2'].",".
            $row['waterDepth'].",".$row['updBoatPos'].",".$row['wavesType'].",".$row['systemMode'];
        echo "OK0".$s;
    }
}else{
    echo "KO0";
}
$conn->close();
?>


























