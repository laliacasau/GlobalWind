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
        echo "OK0";
    } else {
        echo "OK1";
    }
}else{
    echo "KO0";
}
$conn->close();
?>


























