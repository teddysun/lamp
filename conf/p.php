<?php
/* ----------------This probe is based on the YaHei.net probe------------------- */
error_reporting(0); //Suppress all error messages
ini_set('display_errors','Off');
@header("content-Type: text/html; charset=utf-8"); //Language coercion
ob_start();
date_default_timezone_set('Asia/Shanghai');//Time zone setting
$title = 'PHP Probe';
$version = "v0.4.7"; //version
define('HTTP_HOST', preg_replace('~^www\.~i', '', $_SERVER['HTTP_HOST']));
$time_start = microtime_float();
function memory_usage() 
{
    $memory = ( ! function_exists('memory_get_usage')) ? '0' : round(memory_get_usage()/1024/1024, 2).'MB';
    return $memory;
}

// Timing
function microtime_float() 
{
    $mtime = microtime();
    $mtime = explode(' ', $mtime);
    return $mtime[1] + $mtime[0];
}

//Unit conversion
function formatsize($size) 
{
    $danwei=array(' B ',' K ',' M ',' G ',' T ');
    $allsize=array();
    $i=0;
    for($i = 0; $i <5; $i++) 
    {
        if(floor($size/pow(1024,$i))==0){break;}
    }

    for($l = $i-1; $l >=0; $l--) 
    {
        $allsize1[$l]=floor($size/pow(1024,$l));
        $allsize[$l]=$allsize1[$l]-$allsize1[$l+1]*1024;
    }

    $len=count($allsize);

    for($j = $len-1; $j >=0; $j--) 
    {
        $fsize=$fsize.$allsize[$j].$danwei[$j];
    }    
    return $fsize;
}

function valid_email($str) 
{
    return ( ! preg_match("/^([a-z0-9\+_\-]+)(\.[a-z0-9\+_\-]+)*@([a-z0-9\-]+\.)+[a-z]{2,6}$/ix", $str)) ? FALSE : TRUE;
}

//Detect PHP set parameters
function show($varName)
{
    switch($result = get_cfg_var($varName))
    {
        case 0:
            return '<font color="red">×</font>';
        break;
        case 1:
            return '<font color="green">√</font>';
        break;
        default:
            return $result;
        break;
    }
}

//Keep server performance test results
$valInt = isset($_POST['pInt']) ? $_POST['pInt'] : "Not Tested";
$valFloat = isset($_POST['pFloat']) ? $_POST['pFloat'] : "Not Tested";
$valIo = isset($_POST['pIo']) ? $_POST['pIo'] : "Not Tested";

if (isset($_GET['act']) && $_GET['act'] == "phpinfo") 
{
    phpinfo();
    exit();
} 
elseif(isset($_POST['act']) && $_POST['act'] == "Integer Test")
{
    $valInt = test_int();
} 
elseif(isset($_POST['act']) && $_POST['act'] == "Floating Test")
{
    $valFloat = test_float();
} 
elseif(isset($_POST['act']) && $_POST['act'] == "IO Test")
{
    $valIo = test_io();
} 
//Speed ​​test - start
elseif(isset($_POST['act']) && $_POST['act']=="Start Testing")
{
?>
    <script language="javascript" type="text/javascript">
        var acd1;
        acd1 = new Date();
        acd1ok=acd1.getTime();
    </script>
    <?php
    for($i=1;$i<=100000;$i++)
    {
        echo "<!--567890#########0#########0#########0#########0#########0#########0#########0#########012345-->";
    }
    ?>
    <script language="javascript" type="text/javascript">
        var acd2;
        acd2 = new Date();
        acd2ok=acd2.getTime();
        window.location = '?speed=' +(acd2ok-acd1ok)+'#w_networkspeed';
    </script>
<?php
}
elseif(isset($_GET['act']) && $_GET['act'] == "Function")
{
    $arr = get_defined_functions();
    Function php()
    {
    }
    echo "<pre>";
    Echo "This shows all the functions supported by the system, and custom functions\n";
    print_r($arr);
    echo "</pre>";
    exit();
}
elseif(isset($_GET['act']) && $_GET['act'] == "disable_functions")
{
    $disFuns=get_cfg_var("disable_functions");
    if(empty($disFuns))
    {
        $arr = '<font color=red>×</font>';
    }
    else
    { 
        $arr = $disFuns;
    }
    Function php()
    {
    }
    echo "<pre>";
    Echo "This shows all the functions disable by the system\n";
    print_r($arr);
    echo "</pre>";
    exit();
}

//MySQL Test
if (isset($_POST['act']) && $_POST['act'] == 'MySQL Test')
{
    $host = isset($_POST['host']) ? trim($_POST['host']) : '';
    $port = isset($_POST['port']) ? (int) $_POST['port'] : '';
    $login = isset($_POST['login']) ? trim($_POST['login']) : '';
    $password = isset($_POST['password']) ? trim($_POST['password']) : '';
    $host = preg_match('~[^a-z0-9\-\.]+~i', $host) ? '' : $host;
    $port = intval($port) ? intval($port) : '';
    $login = preg_match('~[^a-z0-9\_\-]+~i', $login) ? '' : htmlspecialchars($login);
    $password = is_string($password) ? htmlspecialchars($password) : '';
}
elseif (isset($_POST['act']) && $_POST['act'] == 'Function Test')
{
    $funRe = "Function ".$_POST['funName']." Support status Test results：".isfun1($_POST['funName']);
} 
elseif (isset($_POST['act']) && $_POST['act'] == 'Mail Test')
{
    $mailRe = "Mail sending test result: send";
    if($_SERVER['SERVER_PORT']==80){$mailContent = "http://".$_SERVER['SERVER_NAME'].($_SERVER['PHP_SELF'] ? $_SERVER['PHP_SELF'] : $_SERVER['SCRIPT_NAME']);}
    else{$mailContent = "http://".$_SERVER['SERVER_NAME'].":".$_SERVER['SERVER_PORT'].($_SERVER['PHP_SELF'] ? $_SERVER['PHP_SELF'] : $_SERVER['SCRIPT_NAME']);}
    $mailRe .= (false !== @mail($_POST["mailAdd"], $mailContent, "This is a test mail!")) ? "Complete ":" failed";
}

//Get MySQL version
function getMySQLVersion() {
    $output = shell_exec('mysql -V');
    if (empty($output)){
        return null;
    }
    preg_match('@[0-9]+\.[0-9]+\.[0-9]+@', $output, $version);
    return $version[0];
}

// Network speed test
if(isset($_POST['act']) && $_POST['speed'])
{
    $speed=round(100/($_POST['speed']/1000),2);
}
elseif(isset($_GET['speed']) && $_GET['speed']=="0")
{
    $speed=6666.67;
}
elseif(isset($_GET['speed']) and $_GET['speed']>0)
{
    $speed=round(100/($_GET['speed']/1000),2); //download speed：$speed kb/s
}
else
{
    $speed="<font color=\"red\">&nbsp;Not Test&nbsp;</font>";
}    

// Detection function support
function isfun($funName = '')
{
    if (!$funName || trim($funName) == '' || preg_match('~[^a-z0-9\_]+~i', $funName, $tmp)) return 'error';
    return (false !== function_exists($funName)) ? '<font color="green">√</font>' : '<font color="red">×</font>';
}
function isfun1($funName = '')
{
    if (!$funName || trim($funName) == '' || preg_match('~[^a-z0-9\_]+~i', $funName, $tmp)) return 'error';
    return (false !== function_exists($funName)) ? '√' : '×';
}

//Integer arithmetic capability test
function test_int()
{
    $timeStart = gettimeofday();
    for($i = 0; $i < 3000000; $i++)
    {
        $t = 1+1;
    }
    $timeEnd = gettimeofday();
    $time = ($timeEnd["usec"]-$timeStart["usec"])/1000000+$timeEnd["sec"]-$timeStart["sec"];
    $time = round($time, 3)."Second";
    return $time;
}

//Floating point computing capability test
function test_float()
{
    //Get the pi value
    $t = pi();
    $timeStart = gettimeofday();
    for($i = 0; $i < 3000000; $i++)
    {
        //square
        sqrt($t);
    }

    $timeEnd = gettimeofday();
    $time = ($timeEnd["usec"]-$timeStart["usec"])/1000000+$timeEnd["sec"]-$timeStart["sec"];
    $time = round($time, 3)."Second";
    return $time;
}

//IO capability test
function test_io()
{
    $fp = @fopen(PHPSELF, "r");
    $timeStart = gettimeofday();
    for($i = 0; $i < 10000; $i++) 
    {
        @fread($fp, 10240);
        @rewind($fp);
    }
    $timeEnd = gettimeofday();
    @fclose($fp);
    $time = ($timeEnd["usec"]-$timeStart["usec"])/1000000+$timeEnd["sec"]-$timeStart["sec"];
    $time = round($time, 3)."Second";
    return($time);
}

function GetCoreInformation() {$data = file('/proc/stat');$cores = array();foreach( $data as $line ) {if( preg_match('/^cpu[0-9]/', $line) ){$info = explode(' ', $line);$cores[]=array('user'=>$info[1],'nice'=>$info[2],'sys' => $info[3],'idle'=>$info[4],'iowait'=>$info[5],'irq' => $info[6],'softirq' => $info[7]);}}return $cores;}
function GetCpuPercentages($stat1, $stat2) {if(count($stat1)!==count($stat2)){return;}$cpus=array();for( $i = 0, $l = count($stat1); $i < $l; $i++) {    $dif = array();    $dif['user'] = $stat2[$i]['user'] - $stat1[$i]['user'];$dif['nice'] = $stat2[$i]['nice'] - $stat1[$i]['nice'];    $dif['sys'] = $stat2[$i]['sys'] - $stat1[$i]['sys'];$dif['idle'] = $stat2[$i]['idle'] - $stat1[$i]['idle'];$dif['iowait'] = $stat2[$i]['iowait'] - $stat1[$i]['iowait'];$dif['irq'] = $stat2[$i]['irq'] - $stat1[$i]['irq'];$dif['softirq'] = $stat2[$i]['softirq'] - $stat1[$i]['softirq'];$total = array_sum($dif);$cpu = array();foreach($dif as $x=>$y) $cpu[$x] = round($y / $total * 100, 2);$cpus['cpu' . $i] = $cpu;}return $cpus;}
$stat1 = GetCoreInformation();sleep(1);$stat2 = GetCoreInformation();$data = GetCpuPercentages($stat1, $stat2);
$cpu_show = $data['cpu0']['user']."%us,  ".$data['cpu0']['sys']."%sy,  ".$data['cpu0']['nice']."%ni, ".$data['cpu0']['idle']."%id,  ".$data['cpu0']['iowait']."%wa,  ".$data['cpu0']['irq']."%irq,  ".$data['cpu0']['softirq']."%softirq";
function makeImageUrl($title, $data) {$api='http://api.yahei.net/tz/cpu_show.php?id=';$url.=$data['user'].',';$url.=$data['nice'].',';$url.=$data['sys'].',';$url.=$data['idle'].',';$url.=$data['iowait'];$url.='&chdl=User|Nice|Sys|Idle|Iowait&chdlp=b&chl=';$url.=$data['user'].'%25|';$url.=$data['nice'].'%25|';$url.=$data['sys'].'%25|';$url.=$data['idle'].'%25|';$url.=$data['iowait'].'%25';$url.='&chtt=Core+'.$title;return $api.base64_encode($url);}
if($_GET['act'] == "cpu_percentage"){echo "<center><b><font face='Microsoft YaHei' color='#666666' size='3'>Image loading slow, please be patient！</font></b><br /><br />";foreach( $data as $k => $v ) {echo '<img src="' . makeImageUrl( $k, $v ) . '" style="width:360px;height:240px;border: #CCCCCC 1px solid;background: #FFFFFF;margin:5px;padding:5px;" />';}echo "</center>";exit();}

// According to different systems to obtain CPU-related information
switch(PHP_OS)
{
    case "Linux":
        $sysReShow = (false !== ($sysInfo = sys_linux()))?"show":"none";
    break;
    case "FreeBSD":
        $sysReShow = (false !== ($sysInfo = sys_freebsd()))?"show":"none";
    break;
/*    
    case "WINNT":
        $sysReShow = (false !== ($sysInfo = sys_windows()))?"show":"none";
    break;
*/    
    default:
    break;
}

//linux System detection
function sys_linux()
{
    // CPU
    if (false === ($str = @file("/proc/cpuinfo"))) return false;
    $str = implode("", $str);
    @preg_match_all("/model\s+name\s{0,}\:+\s{0,}([\w\s\)\(\@.-]+)([\r\n]+)/s", $str, $model);
    @preg_match_all("/cpu\s+MHz\s{0,}\:+\s{0,}([\d\.]+)[\r\n]+/", $str, $mhz);
    @preg_match_all("/cache\s+size\s{0,}\:+\s{0,}([\d\.]+\s{0,}[A-Z]+[\r\n]+)/", $str, $cache);
    @preg_match_all("/bogomips\s{0,}\:+\s{0,}([\d\.]+)[\r\n]+/", $str, $bogomips);
    if (false !== is_array($model[1]))
    {
        $res['cpu']['num'] = sizeof($model[1]);
        /*
        for($i = 0; $i < $res['cpu']['num']; $i++)
        {
            $res['cpu']['model'][] = $model[1][$i].'&nbsp;('.$mhz[1][$i].')';
            $res['cpu']['mhz'][] = $mhz[1][$i];
            $res['cpu']['cache'][] = $cache[1][$i];
            $res['cpu']['bogomips'][] = $bogomips[1][$i];
        }*/
        if($res['cpu']['num']==1)
            $x1 = '';
        else
            $x1 = ' ×'.$res['cpu']['num'];
        $mhz[1][0] = ' | frequency:'.$mhz[1][0];
        $cache[1][0] = ' | Secondary cache:'.$cache[1][0];
        $bogomips[1][0] = ' | Bogomips:'.$bogomips[1][0];
        $res['cpu']['model'][] = $model[1][0].$mhz[1][0].$cache[1][0].$bogomips[1][0].$x1;
        if (false !== is_array($res['cpu']['model'])) $res['cpu']['model'] = implode("<br />", $res['cpu']['model']);
        if (false !== is_array($res['cpu']['mhz'])) $res['cpu']['mhz'] = implode("<br />", $res['cpu']['mhz']);
        if (false !== is_array($res['cpu']['cache'])) $res['cpu']['cache'] = implode("<br />", $res['cpu']['cache']);
        if (false !== is_array($res['cpu']['bogomips'])) $res['cpu']['bogomips'] = implode("<br />", $res['cpu']['bogomips']);
    }

    // UPTIME
    if (false === ($str = @file("/proc/uptime"))) return false;
    $str = explode(" ", implode("", $str));
    $str = trim($str[0]);
    $min = $str / 60;
    $hours = $min / 60;
    $days = floor($hours / 24);
    $hours = floor($hours - ($days * 24));
    $min = floor($min - ($days * 60 * 24) - ($hours * 60));
    if ($days !== 0) $res['uptime'] = $days." Days ";
    if ($hours !== 0) $res['uptime'] .= $hours." Hours ";
    $res['uptime'] .= $min." Minutes";

    // MEMORY
    if (false === ($str = @file("/proc/meminfo"))) return false;
    $str = implode("", $str);
    preg_match_all("/MemTotal\s{0,}\:+\s{0,}([\d\.]+).+?MemFree\s{0,}\:+\s{0,}([\d\.]+).+?Cached\s{0,}\:+\s{0,}([\d\.]+).+?SwapTotal\s{0,}\:+\s{0,}([\d\.]+).+?SwapFree\s{0,}\:+\s{0,}([\d\.]+)/s", $str, $buf);
    preg_match_all("/Buffers\s{0,}\:+\s{0,}([\d\.]+)/s", $str, $buffers);
    $res['memTotal'] = round($buf[1][0]/1024, 2);
    $res['memFree'] = round($buf[2][0]/1024, 2);
    $res['memBuffers'] = round($buffers[1][0]/1024, 2);
    $res['memCached'] = round($buf[3][0]/1024, 2);
    $res['memUsed'] = $res['memTotal']-$res['memFree'];
    $res['memPercent'] = (floatval($res['memTotal'])!=0)?round($res['memUsed']/$res['memTotal']*100,2):0;
    $res['memRealUsed'] = $res['memTotal'] - $res['memFree'] - $res['memCached'] - $res['memBuffers']; //Real memory is used
    $res['memRealFree'] = $res['memTotal'] - $res['memRealUsed']; //Really free
    $res['memRealPercent'] = (floatval($res['memTotal'])!=0)?round($res['memRealUsed']/$res['memTotal']*100,2):0; //Real memory usage
    $res['memCachedPercent'] = (floatval($res['memCached'])!=0)?round($res['memCached']/$res['memTotal']*100,2):0; //Cached Memory usage
    $res['swapTotal'] = round($buf[4][0]/1024, 2);
    $res['swapFree'] = round($buf[5][0]/1024, 2);
    $res['swapUsed'] = round($res['swapTotal']-$res['swapFree'], 2);
    $res['swapPercent'] = (floatval($res['swapTotal'])!=0)?round($res['swapUsed']/$res['swapTotal']*100,2):0;

    // LOAD AVG
    if (false === ($str = @file("/proc/loadavg"))) return false;
    $str = explode(" ", implode("", $str));
    $str = array_chunk($str, 4);
    $res['loadAvg'] = implode(" ", $str[0]);

    return $res;
}

//FreeBSD System detection
function sys_freebsd()
{
    //CPU
    if (false === ($res['cpu']['num'] = get_key("hw.ncpu"))) return false;
    $res['cpu']['model'] = get_key("hw.model");
    //LOAD AVG
    if (false === ($res['loadAvg'] = get_key("vm.loadavg"))) return false;
    //UPTIME
    if (false === ($buf = get_key("kern.boottime"))) return false;
    $buf = explode(' ', $buf);
    $sys_ticks = time() - intval($buf[3]);
    $min = $sys_ticks / 60;
    $hours = $min / 60;
    $days = floor($hours / 24);
    $hours = floor($hours - ($days * 24));
    $min = floor($min - ($days * 60 * 24) - ($hours * 60));
    if ($days !== 0) $res['uptime'] = $days."Days ";
    if ($hours !== 0) $res['uptime'] .= $hours."Hours ";
    $res['uptime'] .= $min."Minutes";

    //MEMORY
    if (false === ($buf = get_key("hw.physmem"))) return false;
    $res['memTotal'] = round($buf/1024/1024, 2);
    $str = get_key("vm.vmtotal");
    preg_match_all("/\nVirtual Memory[\:\s]*\(Total[\:\s]*([\d]+)K[\,\s]*Active[\:\s]*([\d]+)K\)\n/i", $str, $buff, PREG_SET_ORDER);
    preg_match_all("/\nReal Memory[\:\s]*\(Total[\:\s]*([\d]+)K[\,\s]*Active[\:\s]*([\d]+)K\)\n/i", $str, $buf, PREG_SET_ORDER);
    $res['memRealUsed'] = round($buf[0][2]/1024, 2);
    $res['memCached'] = round($buff[0][2]/1024, 2);
    $res['memUsed'] = round($buf[0][1]/1024, 2) + $res['memCached'];
    $res['memFree'] = $res['memTotal'] - $res['memUsed'];
    $res['memPercent'] = (floatval($res['memTotal'])!=0)?round($res['memUsed']/$res['memTotal']*100,2):0;
    $res['memRealPercent'] = (floatval($res['memTotal'])!=0)?round($res['memRealUsed']/$res['memTotal']*100,2):0;
    return $res;
}

//Get the parameter value FreeBSD
function get_key($keyName)
{
    return do_command('sysctl', "-n $keyName");
}

//Determine the execution file location FreeBSD
function find_command($commandName)
{
    $path = array('/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin', '/usr/local/sbin');
    foreach($path as $p) 
    {
        if (@is_executable("$p/$commandName")) return "$p/$commandName";
    }
    return false;
}

//Execute system commands FreeBSD
function do_command($commandName, $args)
{
    $buffer = "";
    if (false === ($command = find_command($commandName))) return false;
    if ($fp = @popen("$command $args", 'r')) 
    {
        while (!@feof($fp))
        {
            $buffer .= @fgets($fp, 4096);
        }
        return trim($buffer);
    }
    return false;
}

//windows System detection
function sys_windows()
{
    if (PHP_VERSION >= 5)
    {
        $objLocator = new COM("WbemScripting.SWbemLocator");
        $wmi = $objLocator->ConnectServer();
        $prop = $wmi->get("Win32_PnPEntity");
    }
    else
    {
        return false;
    }

    //CPU
    $cpuinfo = GetWMI($wmi,"Win32_Processor", array("Name","L2CacheSize","NumberOfCores"));
    $res['cpu']['num'] = $cpuinfo[0]['NumberOfCores'];
    if (null == $res['cpu']['num']) 
    {
        $res['cpu']['num'] = 1;
    }
    /*
    for ($i=0;$i<$res['cpu']['num'];$i++)
    {
        $res['cpu']['model'] .= $cpuinfo[0]['Name']."<br />";
        $res['cpu']['cache'] .= $cpuinfo[0]['L2CacheSize']."<br />";
    }*/
    $cpuinfo[0]['L2CacheSize'] = ' ('.$cpuinfo[0]['L2CacheSize'].')';
    if($res['cpu']['num']==1)
        $x1 = '';
    else
        $x1 = ' ×'.$res['cpu']['num'];
    $res['cpu']['model'] = $cpuinfo[0]['Name'].$cpuinfo[0]['L2CacheSize'].$x1;

    // SYSINFO
    $sysinfo = GetWMI($wmi,"Win32_OperatingSystem", array('LastBootUpTime','TotalVisibleMemorySize','FreePhysicalMemory','Caption','CSDVersion','SerialNumber','InstallDate'));
    $sysinfo[0]['Caption']=iconv('GBK', 'UTF-8',$sysinfo[0]['Caption']);
    $sysinfo[0]['CSDVersion']=iconv('GBK', 'UTF-8',$sysinfo[0]['CSDVersion']);
    $res['win_n'] = $sysinfo[0]['Caption']." ".$sysinfo[0]['CSDVersion']." serial number:{$sysinfo[0]['SerialNumber']} in".date('Y-m-d-H:i:s',strtotime(substr($sysinfo[0]['InstallDate'],0,14)))."installation";

    //UPTIME
    $res['uptime'] = $sysinfo[0]['LastBootUpTime'];
    $sys_ticks = 3600*8 + time() - strtotime(substr($res['uptime'],0,14));
    $min = $sys_ticks / 60;
    $hours = $min / 60;
    $days = floor($hours / 24);
    $hours = floor($hours - ($days * 24));
    $min = floor($min - ($days * 60 * 24) - ($hours * 60));
    if ($days !== 0) $res['uptime'] = $days."Day";
    if ($hours !== 0) $res['uptime'] .= $hours."Hour";
    $res['uptime'] .= $min."Minute";

    //MEMORY
    $res['memTotal'] = round($sysinfo[0]['TotalVisibleMemorySize']/1024,2);
    $res['memFree'] = round($sysinfo[0]['FreePhysicalMemory']/1024,2);
    $res['memUsed'] = $res['memTotal']-$res['memFree'];    //The above two lines have been divided by 1024, this line no longer except
    $res['memPercent'] = round($res['memUsed'] / $res['memTotal']*100,2);
    $swapinfo = GetWMI($wmi,"Win32_PageFileUsage", array('AllocatedBaseSize','CurrentUsage'));

    // LoadPercentage
    $loadinfo = GetWMI($wmi,"Win32_Processor", array("LoadPercentage"));
    $res['loadAvg'] = $loadinfo[0]['LoadPercentage'];
    
    return $res;
}

function GetWMI($wmi,$strClass, $strValue = array())
{
    $arrData = array();
    $objWEBM = $wmi->Get($strClass);
    $arrProp = $objWEBM->Properties_;
    $arrWEBMCol = $objWEBM->Instances_();
    foreach($arrWEBMCol as $objItem) 
    {
        @reset($arrProp);
        $arrInstance = array();
        foreach($arrProp as $propItem) 
        {
            eval("\$value = \$objItem->" . $propItem->Name . ";");
            if (empty($strValue)) 
            {
                $arrInstance[$propItem->Name] = trim($value);
            } 
            else
            {
                if (in_array($propItem->Name, $strValue)) 
                {
                    $arrInstance[$propItem->Name] = trim($value);
                }
            }
        }
        $arrData[] = $arrInstance;
    }

    return $arrData;
}

// Proportional bar
function bar($percent)
{
?>
    <div class="bar"><div class="barli" style="width:<?php echo $percent?>%">&nbsp;</div></div>
<?php
}

$uptime = $sysInfo['uptime']; //online time
$stime = date('Y-m-d H:i:s'); //The current time of the system

//hard disk
$dt = round(@disk_total_space(".")/(1024*1024*1024),3); //total
$df = round(@disk_free_space(".")/(1024*1024*1024),3); //Available
$du = $dt-$df; //used
$hdPercent = (floatval($dt)!=0)?round($du/$dt*100,2):0;
$load = $sysInfo['loadAvg'];    //System load

//If the memory is less than 1G, it will display M, otherwise it will display G units
if($sysInfo['memTotal']<1024)
{
    $memTotal = $sysInfo['memTotal']." M";
    $mt = $sysInfo['memTotal']." M";
    $mu = $sysInfo['memUsed']." M";
    $mf = $sysInfo['memFree']." M";
    $mc = $sysInfo['memCached']." M";    //cacheMemory
    $mb = $sysInfo['memBuffers']." M";    //buffer
    $st = $sysInfo['swapTotal']." M";
    $su = $sysInfo['swapUsed']." M";
    $sf = $sysInfo['swapFree']." M";
    $swapPercent = $sysInfo['swapPercent'];
    $memRealUsed = $sysInfo['memRealUsed']." M"; //Real memory is used
    $memRealFree = $sysInfo['memRealFree']." M"; //Real memory is free
    $memRealPercent = $sysInfo['memRealPercent']; //Real memory usage ratio
    $memPercent = $sysInfo['memPercent']; //Total memory usage
    $memCachedPercent = $sysInfo['memCachedPercent']; //Cache memory usage
}
else
{
    $memTotal = round($sysInfo['memTotal']/1024,3)." G";
    $mt = round($sysInfo['memTotal']/1024,3)." G";
    $mu = round($sysInfo['memUsed']/1024,3)." G";
    $mf = round($sysInfo['memFree']/1024,3)." G";
    $mc = round($sysInfo['memCached']/1024,3)." G";
    $mb = round($sysInfo['memBuffers']/1024,3)." G";
    $st = round($sysInfo['swapTotal']/1024,3)." G";
    $su = round($sysInfo['swapUsed']/1024,3)." G";
    $sf = round($sysInfo['swapFree']/1024,3)." G";
    $swapPercent = $sysInfo['swapPercent'];
    $memRealUsed = round($sysInfo['memRealUsed']/1024,3)." G"; //Real memory is used
    $memRealFree = round($sysInfo['memRealFree']/1024,3)." G"; //Real memory is free
    $memRealPercent = $sysInfo['memRealPercent']; //Real memory usage ratio
    $memPercent = $sysInfo['memPercent']; //Total memory usage
    $memCachedPercent = $sysInfo['memCachedPercent']; //cacheMemory usage
}

//Cache memory usage
$strs = @file("/proc/net/dev"); 

for ($i = 2; $i < count($strs); $i++ )
{
    preg_match_all( "/([^\s]+):[\s]{0,}(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/", $strs[$i], $info );
    $NetOutSpeed[$i] = $info[10][0];
    $NetInputSpeed[$i] = $info[2][0];
    $NetInput[$i] = formatsize($info[2][0]);
    $NetOut[$i]  = formatsize($info[10][0]);
}

//ajax call real-time refresh
if ($_GET['act'] == "rt")
{
    $arr=array('useSpace'=>"$du",'freeSpace'=>"$df",'hdPercent'=>"$hdPercent",'barhdPercent'=>"$hdPercent%",'TotalMemory'=>"$mt",'UsedMemory'=>"$mu",'FreeMemory'=>"$mf",'CachedMemory'=>"$mc",'Buffers'=>"$mb",'TotalSwap'=>"$st",'swapUsed'=>"$su",'swapFree'=>"$sf",'loadAvg'=>"$load",'uptime'=>"$uptime",'freetime'=>"$freetime",'bjtime'=>"$bjtime",'stime'=>"$stime",'memRealPercent'=>"$memRealPercent",'memRealUsed'=>"$memRealUsed",'memRealFree'=>"$memRealFree",'memPercent'=>"$memPercent%",'memCachedPercent'=>"$memCachedPercent",'barmemCachedPercent'=>"$memCachedPercent%",'swapPercent'=>"$swapPercent",'barmemRealPercent'=>"$memRealPercent%",'barswapPercent'=>"$swapPercent%",'NetOut2'=>"$NetOut[2]",'NetOut3'=>"$NetOut[3]",'NetOut4'=>"$NetOut[4]",'NetOut5'=>"$NetOut[5]",'NetOut6'=>"$NetOut[6]",'NetOut7'=>"$NetOut[7]",'NetOut8'=>"$NetOut[8]",'NetOut9'=>"$NetOut[9]",'NetOut10'=>"$NetOut[10]",'NetInput2'=>"$NetInput[2]",'NetInput3'=>"$NetInput[3]",'NetInput4'=>"$NetInput[4]",'NetInput5'=>"$NetInput[5]",'NetInput6'=>"$NetInput[6]",'NetInput7'=>"$NetInput[7]",'NetInput8'=>"$NetInput[8]",'NetInput9'=>"$NetInput[9]",'NetInput10'=>"$NetInput[10]",'NetOutSpeed2'=>"$NetOutSpeed[2]",'NetOutSpeed3'=>"$NetOutSpeed[3]",'NetOutSpeed4'=>"$NetOutSpeed[4]",'NetOutSpeed5'=>"$NetOutSpeed[5]",'NetInputSpeed2'=>"$NetInputSpeed[2]",'NetInputSpeed3'=>"$NetInputSpeed[3]",'NetInputSpeed4'=>"$NetInputSpeed[4]",'NetInputSpeed5'=>"$NetInputSpeed[5]");
    $jarr=json_encode($arr); 
    $_GET['callback'] = htmlspecialchars($_GET['callback']);
    echo $_GET['callback'],'(',$jarr,')';
    exit;
}
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><?php echo $title; ?></title>
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<style type="text/css">
<!--
* {font-family: Microsoft Yahei, Tahoma, Arial; }
body{text-align: center; margin: 0 auto; padding: 0; background-color:#fafafa;font-size:12.5px;font-family:Microsoft Yahei, Tahoma, Arial}
h1 {font-size: 26px; padding: 0; margin: 0; color: #333333; font-family: "Lucida Sans Unicode","Lucida Grande",sans-serif;}
h1 small {font-size: 11px; font-family: Tahoma; font-weight: bold; }
a{color: #666; text-decoration:none;}
a.black{color: #000000; text-decoration:none;}
table{width:100%;clear:both;padding: 0; margin: 0 0 10px;border-collapse:collapse; border-spacing: 0;
box-shadow: 1px 1px 1px #CCC;
-moz-box-shadow: 1px 1px 1px #CCC;
-webkit-box-shadow: 1px 1px 1px #CCC;
-ms-filter: "progid:DXImageTransform.Microsoft.Shadow(Strength=2, Direction=135, Color='#CCCCCC')";}
th{padding: 3px 6px; font-weight:bold;background:#dedede;color:#626262;border:1px solid #cccccc; text-align:left;}
tr{padding: 0; background:#FFFFFF;}
td{padding: 3px 6px; border:1px solid #CCCCCC;}
.w_logo{height:25px;text-align:left;color:#333;FONT-SIZE: 15px; width:13%; }
.w_top{height:25px;text-align:center; width:8.7%;}
.w_top:hover{background:#dadada;}
.w_foot{height:25px;text-align:center; background:#dedede;}
input{padding: 2px; background: #FFFFFF; border-top:1px solid #666666; border-left:1px solid #666666; border-right:1px solid #CCCCCC; border-bottom:1px solid #CCCCCC; font-size:12px}
input.btn{font-weight: bold; height: 20px; line-height: 20px; padding: 0 6px; color:#666666; background: #f2f2f2; border:1px solid #999;font-size:12px}
.bar {border:1px solid #999999; background:#FFFFFF; height:5px; font-size:2px; width:89%; margin:2px 0 5px 0;padding:1px; overflow: hidden;}
.bar_1 {border:1px dotted #999999; background:#FFFFFF; height:5px; font-size:2px; width:89%; margin:2px 0 5px 0;padding:1px; overflow: hidden;}
.barli_red{background:#ff6600; height:5px; margin:0px; padding:0;}
.barli_blue{background:#0099FF; height:5px; margin:0px; padding:0;}
.barli_green{background:#36b52a; height:5px; margin:0px; padding:0;}
.barli_black{background:#333; height:5px; margin:0px; padding:0;}
.barli_1{background:#999999; height:5px; margin:0px; padding:0;}
.barli{background:#36b52a; height:5px; margin:0px; padding:0;}
#page {width: 960px; padding: 0 auto; margin: 0 auto; text-align: left;}
#header{position:relative; padding:5px;}
.w_small{font-size: 14px; font-family: Consolas;}
.w_number{color: #f800fe;}
.sudu {padding: 0; background:#5dafd1; }
.suduk { margin:0px; padding:0;}
.resYes{}
.resNo{color: #FF0000;}
.word{font-size: 14px; font-family: Consolas; word-break: break-all;}
.static{color: #009900;}
-->
</style>
<script language="JavaScript" type="text/javascript" src="./jquery.js"></script>
<script type="text/javascript"> 
<!--
$(document).ready(function(){getJSONData();});
var OutSpeed2=<?php echo floor($NetOutSpeed[2]) ?>;
var OutSpeed3=<?php echo floor($NetOutSpeed[3]) ?>;
var OutSpeed4=<?php echo floor($NetOutSpeed[4]) ?>;
var OutSpeed5=<?php echo floor($NetOutSpeed[5]) ?>;
var InputSpeed2=<?php echo floor($NetInputSpeed[2]) ?>;
var InputSpeed3=<?php echo floor($NetInputSpeed[3]) ?>;
var InputSpeed4=<?php echo floor($NetInputSpeed[4]) ?>;
var InputSpeed5=<?php echo floor($NetInputSpeed[5]) ?>;

function getJSONData()
{
    setTimeout("getJSONData()", 1000);
    $.getJSON('?act=rt&callback=?', displayData);
}
function ForDight(Dight,How)
{ 
  if (Dight<0){
      var Last=0+"B/s";
  }else if (Dight<1024){
      var Last=Math.round(Dight*Math.pow(10,How))/Math.pow(10,How)+"B/s";
  }else if (Dight<1048576){
      Dight=Dight/1024;
      var Last=Math.round(Dight*Math.pow(10,How))/Math.pow(10,How)+"K/s";
  }else{
      Dight=Dight/1048576;
      var Last=Math.round(Dight*Math.pow(10,How))/Math.pow(10,How)+"M/s";
  }
    return Last; 
}

function displayData(dataJSON)
{
    $("#useSpace").html(dataJSON.useSpace);
    $("#freeSpace").html(dataJSON.freeSpace);
    $("#hdPercent").html(dataJSON.hdPercent);
    $("#barhdPercent").width(dataJSON.barhdPercent);
    $("#TotalMemory").html(dataJSON.TotalMemory);
    $("#UsedMemory").html(dataJSON.UsedMemory);
    $("#FreeMemory").html(dataJSON.FreeMemory);
    $("#CachedMemory").html(dataJSON.CachedMemory);
    $("#Buffers").html(dataJSON.Buffers);
    $("#TotalSwap").html(dataJSON.TotalSwap);
    $("#swapUsed").html(dataJSON.swapUsed);
    $("#swapFree").html(dataJSON.swapFree);
    $("#swapPercent").html(dataJSON.swapPercent);
    $("#loadAvg").html(dataJSON.loadAvg);
    $("#uptime").html(dataJSON.uptime);
    $("#freetime").html(dataJSON.freetime);
    $("#stime").html(dataJSON.stime);
    $("#bjtime").html(dataJSON.bjtime);
    $("#memRealUsed").html(dataJSON.memRealUsed);
    $("#memRealFree").html(dataJSON.memRealFree);
    $("#memRealPercent").html(dataJSON.memRealPercent);
    $("#memPercent").html(dataJSON.memPercent);
    $("#barmemPercent").width(dataJSON.memPercent);
    $("#barmemRealPercent").width(dataJSON.barmemRealPercent);
    $("#memCachedPercent").html(dataJSON.memCachedPercent);
    $("#barmemCachedPercent").width(dataJSON.barmemCachedPercent);
    $("#barswapPercent").width(dataJSON.barswapPercent);
    $("#NetOut2").html(dataJSON.NetOut2);
    $("#NetOut3").html(dataJSON.NetOut3);
    $("#NetOut4").html(dataJSON.NetOut4);
    $("#NetOut5").html(dataJSON.NetOut5);
    $("#NetOut6").html(dataJSON.NetOut6);
    $("#NetOut7").html(dataJSON.NetOut7);
    $("#NetOut8").html(dataJSON.NetOut8);
    $("#NetOut9").html(dataJSON.NetOut9);
    $("#NetOut10").html(dataJSON.NetOut10);
    $("#NetInput2").html(dataJSON.NetInput2);
    $("#NetInput3").html(dataJSON.NetInput3);
    $("#NetInput4").html(dataJSON.NetInput4);
    $("#NetInput5").html(dataJSON.NetInput5);
    $("#NetInput6").html(dataJSON.NetInput6);
    $("#NetInput7").html(dataJSON.NetInput7);
    $("#NetInput8").html(dataJSON.NetInput8);
    $("#NetInput9").html(dataJSON.NetInput9);
    $("#NetInput10").html(dataJSON.NetInput10);    
    $("#NetOutSpeed2").html(ForDight((dataJSON.NetOutSpeed2-OutSpeed2),3));
    OutSpeed2=dataJSON.NetOutSpeed2;
    $("#NetOutSpeed3").html(ForDight((dataJSON.NetOutSpeed3-OutSpeed3),3));
    OutSpeed3=dataJSON.NetOutSpeed3;
    $("#NetOutSpeed4").html(ForDight((dataJSON.NetOutSpeed4-OutSpeed4),3));
    OutSpeed4=dataJSON.NetOutSpeed4;
    $("#NetOutSpeed5").html(ForDight((dataJSON.NetOutSpeed5-OutSpeed5),3));
    OutSpeed5=dataJSON.NetOutSpeed5;
    $("#NetInputSpeed2").html(ForDight((dataJSON.NetInputSpeed2-InputSpeed2),3));
    InputSpeed2=dataJSON.NetInputSpeed2;
    $("#NetInputSpeed3").html(ForDight((dataJSON.NetInputSpeed3-InputSpeed3),3));
    InputSpeed3=dataJSON.NetInputSpeed3;
    $("#NetInputSpeed4").html(ForDight((dataJSON.NetInputSpeed4-InputSpeed4),3));
    InputSpeed4=dataJSON.NetInputSpeed4;
    $("#NetInputSpeed5").html(ForDight((dataJSON.NetInputSpeed5-InputSpeed5),3));
    InputSpeed5=dataJSON.NetInputSpeed5;
}
-->
</script>
</head>

<body>
<a name="w_top"></a>
<div id="page">
    <table>
        <tr>
            <th class="w_logo">PHP Probe</th>
        </tr>
    </table>
<!--Server related parameters -->
<table>
  <tr><th colspan="4">Server Parameters</th></tr>
  <tr>
    <td>Server Domain/IP</td>
    <td colspan="3"><?php echo @get_current_user();?> - <?php echo $_SERVER['SERVER_NAME'];?>(<?php if('/'==DIRECTORY_SEPARATOR){echo $_SERVER['SERVER_ADDR'];}else{echo @gethostbyname($_SERVER['SERVER_NAME']);} ?>)&nbsp;&nbsp;Your IP address is：<?php echo @$_SERVER['REMOTE_ADDR'];?></td>
  </tr>

  <tr>
    <td>Server ID</td>

    <td colspan="3"><?php echo php_uname();?></td>

  </tr>

  <tr>
    <td width="13%">Server OS</td>
    <td width="40%"><?php $os = explode(" ", php_uname()); echo $os[0];?> &nbsp;Kernel version：<?php if('/'==DIRECTORY_SEPARATOR){echo $os[2];}else{echo $os[1];} ?></td>
    <td width="13%">Web Server</td>
    <td width="34%"><?php echo $_SERVER['SERVER_SOFTWARE'];?></td>
  </tr>

  <tr>
    <td>Server Language</td>
    <td><?php echo getenv("HTTP_ACCEPT_LANGUAGE");?></td>
    <td>Server Port</td>
    <td><?php echo $_SERVER['SERVER_PORT'];?></td>
  </tr>

  <tr>
      <td>Server Hostname</td>
      <td><?php if('/'==DIRECTORY_SEPARATOR ){echo $os[1];}else{echo $os[2];} ?></td>
      <td>Root Path</td>
      <td><?php echo $_SERVER['DOCUMENT_ROOT']?str_replace('\\','/',$_SERVER['DOCUMENT_ROOT']):str_replace('\\','/',dirname(__FILE__));?></td>
    </tr>

  <tr>
      <td>Server Admin</td>
      <td><?php if(isset($_SERVER['SERVER_ADMIN'])) echo $_SERVER['SERVER_ADMIN'];?></td>
        <td>Prober Path</td>
        <td><?php echo str_replace('\\','/',__FILE__)?str_replace('\\','/',__FILE__):$_SERVER['SCRIPT_FILENAME'];?></td>
    </tr>    
</table>

<?if("show"==$sysReShow){?>
<table>
  <tr><th colspan="6">Server Real time Data</th></tr>

  <tr>
    <td width="13%" >Current Time</td>
    <td width="40%" ><span id="stime"><?php echo $stime;?></span></td>
    <td width="13%" >Server Uptime</td>
    <td width="34%" colspan="3"><span id="uptime"><?php echo $uptime;?></span></td>
  </tr>
  <tr>
    <td width="13%">CPU Model [<?php echo $sysInfo['cpu']['num'];?>Core]</td>
    <td width="87%" colspan="5"><?php echo $sysInfo['cpu']['model'];?></td>
  </tr>
  <tr>
    <td>CPU Usage</td>
    <td colspan="5"><?php if('/'==DIRECTORY_SEPARATOR){echo $cpu_show." | <a href='?act=cpu_percentage' target='_blank' class='static'>View the chart</a>";}else{echo "Temporarily only support Linux system";}?>
	</td>
  </tr>
  <tr>
    <td>Space Usage</td>
    <td colspan="5">
        Total Space <?php echo $dt;?>&nbsp;G，
        Used <font color='#333333'><span id="useSpace"><?php echo $du;?></span></font>&nbsp;G，
        Free <font color='#333333'><span id="freeSpace"><?php echo $df;?></span></font>&nbsp;G，
        Rate <span id="hdPercent"><?php echo $hdPercent;?></span>%
        <div class="bar"><div id="barhdPercent" class="barli_black" style="width:<?php echo $hdPercent;?>%" >&nbsp;</div> </div>
    </td>
  </tr>
  <tr>
        <td>Memory Usage</td>
        <td colspan="5">
<?php
$tmp = array(
    'memTotal', 'memUsed', 'memFree', 'memPercent',
    'memCached', 'memRealPercent',
    'swapTotal', 'swapUsed', 'swapFree', 'swapPercent'
);
foreach ($tmp AS $v) {
    $sysInfo[$v] = $sysInfo[$v] ? $sysInfo[$v] : 0;
}
?>
          Total Memory:
          <font color='#CC0000'><?php echo $memTotal;?> </font>
           , Used
          <font color='#CC0000'><span id="UsedMemory"><?php echo $mu;?></span></font>
          , Free
          <font color='#CC0000'><span id="FreeMemory"><?php echo $mf;?></span></font>
          , Rate
          <span id="memPercent"><?php echo $memPercent;?></span>
          <div class="bar"><div id="barmemPercent" class="barli_green" style="width:<?php echo $memPercent?>%" >&nbsp;</div> </div>
<?php
//If the cache is 0, it is not displayed
if($sysInfo['memCached']>0)
{
?>        
          Cache Memory <span id="CachedMemory"><?php echo $mc;?></span>
          , Rate
          <span id="memCachedPercent"><?php echo $memCachedPercent;?></span>
          %    | Buffers <span id="Buffers"><?php echo $mb;?></span>
          <div class="bar"><div id="barmemCachedPercent" class="barli_blue" style="width:<?php echo $memCachedPercent?>%" >&nbsp;</div></div>
          Real Memory Used
          <span id="memRealUsed"><?php echo $memRealUsed;?></span>
          , Real Memory Free
          <span id="memRealFree"><?php echo $memRealFree;?></span>
          , Rate
          <span id="memRealPercent"><?php echo $memRealPercent;?></span>
          %
          <div class="bar_1"><div id="barmemRealPercent" class="barli_1" style="width:<?php echo $memRealPercent?>%" >&nbsp;</div></div> 
<?php
}
//If the SWAP area is 0, it is not displayed
if($sysInfo['swapTotal']>0)
{
?>    
          SWAP:
          <?php echo $st;?>
          , Used
          <span id="swapUsed"><?php echo $su;?></span>
          , Free
          <span id="swapFree"><?php echo $sf;?></span>
          , Rate
          <span id="swapPercent"><?php echo $swapPercent;?></span>
          %
          <div class="bar"><div id="barswapPercent" class="barli_red" style="width:<?php echo $swapPercent?>%" >&nbsp;</div> </div>

<?php
}    
?>          
        </td>
    </tr>

    <tr>
        <td>System Load</td>
        <td colspan="5" class="w_number"><span id="loadAvg"><?php echo $load;?></span></td>
    </tr>
</table>
<?}?>

<?php if (false !== ($strs = @file("/proc/net/dev"))) : ?>
<table>
    <tr><th colspan="5">Network</th></tr>
<?php for ($i = 2; $i < count($strs); $i++ ) : ?>
<?php preg_match_all( "/([^\s]+):[\s]{0,}(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/", $strs[$i], $info );?>
     <tr>
        <td width="13%"><?php echo $info[1][0]?> : </td>
        <td width="29%">In: <font color='#CC0000'><span id="NetInput<?php echo $i?>"><?php echo $NetInput[$i]?></span></font></td>
        <td width="14%">Real time: <font color='#CC0000'><span id="NetInputSpeed<?php echo $i?>">0B/s</span></font></td>
        <td width="29%">Out : <font color='#CC0000'><span id="NetOut<?php echo $i?>"><?php echo $NetOut[$i]?></span></font></td>
        <td width="14%">Real time: <font color='#CC0000'><span id="NetOutSpeed<?php echo $i?>">0B/s</span></font></td>
    </tr>

<?php endfor; ?>
</table>
<?php endif; ?>

<table width="100%" cellpadding="3" cellspacing="0" align="center">
  <tr>
    <th colspan="4">PHP Modules</th>
  </tr>
  <tr>
    <td colspan="4"><span class="w_small">
<?php
$able=get_loaded_extensions();
foreach ($able as $key=>$value) {
    if ($key!=0 && $key%13==0) {
        echo '<br />';
    }
    echo "$value&nbsp;&nbsp;";
}
?></span>
    </td>
  </tr>
</table>

<a name="w_php"></a>
<table>
  <tr><th colspan="4">PHP Parameters</th></tr>
  <tr>
    <td width="30%">PHP information </td>
    <td width="20%">
        <?php
        $phpSelf = $_SERVER['PHP_SELF'] ? $_SERVER['PHP_SELF'] : $_SERVER['SCRIPT_NAME'];
        $disFuns=get_cfg_var("disable_functions");
        ?>
        <?php echo "<a href='?act=phpinfo' target='_blank' class='static'>PHPINFO</a>";?>
    </td>
    <td width="30%">PHP Version </td>
    <td width="20%"><?php echo PHP_VERSION;?></td>
  </tr>

  <tr>
    <td>Run PHP </td>
    <td><?php echo strtoupper(php_sapi_name());?></td>
    <td>Memory Limit </td>
    <td><?php echo show("memory_limit");?></td>
  </tr>

  <tr>
    <td>PHP Safe Mode </td>
    <td><?php echo show("safe_mode");?></td>
    <td>POST Max Size </td>
    <td><?php echo show("post_max_size");?></td>
  </tr>

  <tr>
    <td>Upload Max Filesize</td>
    <td><?php echo show("upload_max_filesize");?></td>
    <td>Floating point data of significant digits </td>
    <td><?php echo show("precision");?></td>
  </tr>

  <tr>
    <td>Max Execution Time </td>
    <td><?php echo show("max_execution_time");?> Second</td>
    <td>Socket TimeOut </td>
    <td><?php echo show("default_socket_timeout");?> Second</td>
  </tr>

  <tr>
    <td>PHP Doc Root </td>
    <td><?php echo show("doc_root");?></td>
    <td>User Dir </td>
    <td><?php echo show("user_dir");?></td>
  </tr>

  <tr>
    <td>Enable Dl </td>
    <td><?php echo show("enable_dl");?></td>
    <td>Set Include Path </td>
    <td><?php echo show("set_include_path");?></td>
  </tr>

  <tr>
    <td>Display Errors </td>
    <td><?php echo show("display_errors");?></td>
    <td>Register Globals </td>
    <td><?php echo show("register_globals");?></td>
  </tr>

  <tr>
    <td>Magic Quotes Gpc </td>
    <td><?php echo show("magic_quotes_gpc");?></td>
    <td>"&lt;?...?&gt;"Short Open Tag </td>
    <td><?php echo show("short_open_tag");?></td>
  </tr>

  <tr>
    <td>"&lt;% %&gt;"ASP Tags </td>
    <td><?php echo show("asp_tags");?></td>
    <td>Ignore Repeated Errors </td>
    <td><?php echo show("ignore_repeated_errors");?></td>
  </tr>

  <tr>
    <td>Ignore Repeated Source </td>
    <td><?php echo show("ignore_repeated_source");?></td>
    <td>Report Memory leaks </td>
    <td><?php echo show("report_memleaks");?></td>
  </tr>

  <tr>
    <td>Disabling Magic Quotes </td>
    <td><?php echo show("magic_quotes_gpc");?></td>
    <td>Magic Quotes Runtime </td>
    <td><?php echo show("magic_quotes_runtime");?></td>
  </tr>

  <tr>
    <td>Allow URL fopen </td>
    <td><?php echo show("allow_url_fopen");?></td>
    <td>Register Argc Argv </td>
    <td><?php echo show("register_argc_argv");?></td>
  </tr>

  <tr>
    <td>Cookie </td>
    <td><?php echo isset($_COOKIE)?'<font color="green">√</font>' : '<font color="red">×</font>';?></td>
    <td>PSpell Check </td>
    <td><?php echo isfun("pspell_check");?></td>
  </tr>
   <tr>
    <td>BCMath </td>
    <td><?php echo isfun("bcadd");?></td>
    <td>PCRE </td>
    <td><?php echo isfun("preg_match");?></td>
  </tr>

  <tr>
    <td>PDF </td>
    <td><?php echo isfun("pdf_close");?></td>
    <td>SNMP </td>
    <td><?php echo isfun("snmpget");?></td>
  </tr> 
   <tr>
    <td>Vmailmgr </td>
    <td><?php echo isfun("vm_adduser");?></td>
    <td>Curl </td>
    <td><?php echo isfun("curl_init");?></td>
  </tr> 
   <tr>
    <td>SMTP </td>
    <td><?php echo get_cfg_var("SMTP")?'<font color="green">√</font>' : '<font color="red">×</font>';?></td>
    <td>SMTP Address</td>
    <td><?php echo get_cfg_var("SMTP")?get_cfg_var("SMTP"):'<font color="red">×</font>';?></td>
  </tr> 

  <tr>
    <td>Enable Functions </td>
    <td colspan="3"><a href='<?php echo $phpSelf;?>?act=Function' target='_blank' class='static'>Please click here for details</a></td>        
  </tr>

  <tr>
    <td>Disable Functions </td>
    <td colspan="3" class="word">
<?php 
$disFuns=get_cfg_var("disable_functions");
if(empty($disFuns))
{
    echo '<font color=red>×</font>';
}
else
{ 
    //echo $disFuns;
    $disFuns_array =  explode(',',$disFuns);
    foreach ($disFuns_array as $key=>$value) 
    {
        if ($key!=0 && $key%6==0) {
            echo '<br />';
    }
    echo "$value&nbsp;&nbsp;";
}    
}
?>
    </td>
  </tr>
</table>

<a name="w_module"></a>
<!--Component information -->
<table>
  <tr><th colspan="4" >Components</th></tr>

  <tr>
    <td width="30%">FTP </td>
    <td width="20%"><?php echo isfun("ftp_login");?></td>
    <td width="30%">XML </td>
    <td width="20%"><?php echo isfun("xml_set_object");?></td>
  </tr>

  <tr>
    <td>Session </td>
    <td><?php echo isfun("session_start");?></td>
    <td>Socket </td>
    <td><?php echo isfun("socket_accept");?></td>
  </tr>

  <tr>
    <td>Calendar </td>
    <td><?php echo isfun('cal_days_in_month');?></td>
    <td>Allow URL Fopen </td>
    <td><?php echo show("allow_url_fopen");?></td>
  </tr>

  <tr>
    <td>GD Library </td>
    <td>
    <?php
        if(function_exists(gd_info)) {
            $gd_info = @gd_info();
            echo $gd_info["GD Version"];
        }else{echo '<font color="red">×</font>';}
    ?></td>
    <td>Zlib </td>
    <td><?php echo isfun("gzclose");?></td>
  </tr>

  <tr>
    <td>IMAP </td>
    <td><?php echo isfun("imap_close");?></td>
    <td>Jdtogregorian </td>
    <td><?php echo isfun("JDToGregorian");?></td>
  </tr>

  <tr>
    <td>Regular Expression </td>
    <td><?php echo isfun("preg_match");?></td>
    <td>WDDX </td>
    <td><?php echo isfun("wddx_add_vars");?></td>
  </tr>

  <tr>
    <td>iconv Encoding </td>
    <td><?php echo isfun("iconv");?></td>
    <td>mbstring </td>
    <td><?php echo isfun("mb_eregi");?></td>
  </tr>

  <tr>
    <td>BCMath </td>
    <td><?php echo isfun("bcadd");?></td>
    <td>LDAP </td>
    <td><?php echo isfun("ldap_close");?></td>
  </tr>

  <tr>
    <td>MCrypt </td>
    <td><?php echo isfun("mcrypt_module_open");?></td>
    <td>Mhash </td>
    <td><?php echo isfun("mhash_count");?></td>
  </tr>
</table>

<a name="w_module_other"></a>
<!--Third party component information -->
<table>
  <tr><th colspan="4" >Other Components</th></tr>
  <tr>
    <td width="30%">Zend Version</td>
    <td width="20%"><?php $zend_version = zend_version();if(empty($zend_version)){echo '<font color=red>×</font>';}else{echo '<font color=green>√</font>　Ver ';echo $zend_version;}?></td>
    <td width="30%">
<?php
$PHP_VERSION = PHP_VERSION;
$PHP_VERSION = substr($PHP_VERSION,0,1);
if($PHP_VERSION > 2)
{
    echo "Zend Guard Loader";
}
else
{
    echo "Zend Optimizer";
}
?>
    </td>
    <td width="20%"><?php if($PHP_VERSION > 2){if(function_exists("zend_loader_version")){ echo '<font color=green>√</font>　Ver ';echo zend_loader_version();} else { echo '<font color=red>×</font>';}} else{if(function_exists('zend_optimizer_version')){ echo '<font color=green>√</font>　Ver ';echo zend_optimizer_version();}else{    echo (get_cfg_var("zend_optimizer.optimization_level")||get_cfg_var("zend_extension_manager.optimizer_ts")||get_cfg_var("zend.ze1_compatibility_mode")||get_cfg_var("zend_extension_ts"))?'<font color=green>√</font>':'<font color=red>×</font>';}}?></td>
  </tr>

  <tr>
    <td>eAccelerator</td>
    <td><?php if((phpversion('eAccelerator'))!=''){echo '<font color=green>√</font>　Ver ';echo phpversion('eAccelerator');}else{ echo "<font color=red>×</font>";} ?></td>
    <td>ionCube Loader</td>
    <td><?php if(extension_loaded('ionCube Loader')){   $ys = ioncube_loader_iversion();   $gm = ".".(int)substr($ys,3,2);   echo '<font color=green>√</font>　Ver ';echo ionCube_Loader_version().$gm;}else{echo "<font color=red>×</font>";}?></td>
  </tr>

  <tr>
    <td>XCache</td>
    <td><?php if((phpversion('XCache'))!=''){echo '<font color=green>√</font>　Ver ';echo phpversion('XCache');}else{ echo "<font color=red>×</font>";} ?></td>
    <td>Zend OPcache</td>
    <td><?php if(function_exists('opcache_get_configuration')){echo '<font color=green>√</font>　Ver ';$configuration=call_user_func('opcache_get_configuration'); echo $configuration['version']['version'];}else{ echo "<font color=red>×</font>";} ?></td>
  </tr>
</table>

<a name="w_db"></a>
<!--Database support -->
<table>
  <tr><th colspan="4">Database</th></tr>

  <tr>
    <td width="30%">MySQL </td>
    <td width="20%"><?php echo isfun("mysqli_connect"); ?>
    <?php $mysql_ver = getMySQLVersion(); if(!empty($mysql_ver)){ echo "&nbsp;&nbsp;Ver&nbsp;" . $mysql_ver;} ?>
    </td>
    <td width="30%">ODBC </td>
    <td width="20%"><?php echo isfun("odbc_close");?></td>
  </tr>

  <tr>
    <td>Oracle OCI8 </td>
    <td><?php echo isfun("oci_close");?></td>
    <td>SQL Server </td>
    <td><?php echo isfun("mssql_close");?></td>
  </tr>

  <tr>
    <td>dBASE </td>
    <td><?php echo isfun("dbase_close");?></td>
    <td>mSQL </td>
    <td><?php echo isfun("msql_close");?></td>
  </tr>

  <tr>
    <td>SQLite </td>
    <td><?php if(extension_loaded('sqlite3')) {$sqliteVer = SQLite3::version();echo '<font color=green>√</font>　Ver ';echo $sqliteVer[versionString];}else {echo isfun("sqlite_close");if(isfun("sqlite_close") == '<font color="green">√</font>　') {echo "Ver ".@sqlite_libversion();}}?></td>
    <td>Hyperwave </td>
    <td><?php echo isfun("hw_close");?></td>
  </tr>

  <tr>
    <td>Postgre SQL </td>
    <td><?php echo isfun("pg_close"); ?></td>
    <td>Informix </td>
    <td><?php echo isfun("ifx_close");?></td>
  </tr>

  <tr>
    <td>DBA database </td>
    <td><?php echo isfun("dba_close");?></td>
    <td>DBM database </td>
    <td><?php echo isfun("dbmclose");?></td>
  </tr>

  <tr>
    <td>FilePro database </td>
    <td><?php echo isfun("filepro_fieldcount");?></td>
    <td>SyBase database </td>
    <td><?php echo isfun("sybase_close");?></td>
  </tr> 
</table>

<a name="w_performance"></a><a name="bottom"></a>
<form action="<?php echo $_SERVER[PHP_SELF]."#bottom";?>" method="post">
<!-- Server performance test -->
<table>
  <tr><th colspan="5">Server performance Test</th></tr>

  <tr align="center">
    <td width="19%">Reference Object</td>
    <td width="17%">Int Test<br />(1+1 Count 3 Million)</td>
    <td width="17%">Float Test<br />(Pi times the square root of 3 million)</td>
    <td width="17%">I/O Test<br />(10K file read 10,000 times)</td>
    <td width="30%">CPU Information</td>
  </tr>

  <tr align="center">
    <td>Linode</td>
    <td>0.357 Second</td>
    <td>0.802 Second</td>
    <td>0.023 Second</td>
    <td align="left">4 x Xeon L5520 @ 2.27GHz</td>
  </tr> 

  <tr align="center">
    <td>PhotonVPS.com</td>
    <td>0.431 Second</td>
    <td>1.024 Second</td>
    <td>0.034 Second</td>
    <td align="left">8 x Xeon E5520 @ 2.27GHz</td>
  </tr>

  <tr align="center">
    <td>SpaceRich.com</td>
    <td>0.421 Second</td>
    <td>1.003 Second</td>
    <td>0.038 Second</td>
    <td align="left">4 x Core i7 920 @ 2.67GHz</td>
  </tr>

  <tr align="center">
    <td>RiZie.com</td>
    <td>0.521 Second</td>
    <td>1.559 Second</td>
    <td>0.054 Second</td>
    <td align="left">2 x Pentium4 3.00GHz</td>
  </tr>

  <tr align="center">
    <td>CitynetHost.com</a></td>
    <td>0.343 Second</td>
    <td>0.761 Second</td>
    <td>0.023 Second</td>
    <td align="left">2 x Core2Duo E4600 @ 2.40GHz</td>
  </tr>

  <tr align="center">
    <td>IXwebhosting.com</td>
    <td>0.535 Second</td>
    <td>1.607 Second</td>
    <td>0.058 Second</td>
    <td align="left">4 x Xeon E5530 @ 2.40GHz</td>
  </tr>

  <tr align="center">
    <td>This Server</td>
    <td><?php echo $valInt;?><br /><input class="btn" name="act" type="submit" value="Integer Test" /></td>
    <td><?php echo $valFloat;?><br /><input class="btn" name="act" type="submit" value="Floating Test" /></td>
    <td><?php echo $valIo;?><br /><input class="btn" name="act" type="submit" value="IO Test" /></td>
    <td></td>
  </tr>
</table>

<input type="hidden" name="pInt" value="<?php echo $valInt;?>" />
<input type="hidden" name="pFloat" value="<?php echo $valFloat;?>" />
<input type="hidden" name="pIo" value="<?php echo $valIo;?>" />

<a name="w_networkspeed"></a>
<!-- Network speed test-->
<table>
    <tr><th colspan="3">Network Speed Test</th></tr>
  <tr>
    <td width="19%" align="center"><input name="act" type="submit" class="btn" value="Start Testing" />
    <br />
    1000k bytes sent to the client data
    </td>
    <td width="81%" align="center" >

  <table align="center" width="550" border="0" cellspacing="0" cellpadding="0" >
    <tr >
    <td height="15" width="50">Bandwidth</td>
    <td height="15" width="50">1M</td>
    <td height="15" width="50">2M</td>
    <td height="15" width="50">3M</td>
    <td height="15" width="50">4M</td>
    <td height="15" width="50">5M</td>
    <td height="15" width="50">6M</td>
    <td height="15" width="50">7M</td>
    <td height="15" width="50">8M</td>
    <td height="15" width="50">9M</td>
    <td height="15" width="50">10M</td>
    </tr>
   <tr>
    <td colspan="11" class="suduk" ><table align="center" width="550" border="0" cellspacing="0" cellpadding="0" height="8" class="suduk">
    <tr>
      <td class="sudu"  width="<?php 
    if(preg_match("/[^\d-., ]/",$speed))
        {
            echo "0";
        }
    else{
            echo 550*($speed/11000);
        } 
        ?>"></td>
      <td class="suduk" width="<?php 
    if(preg_match("/[^\d-., ]/",$speed))
        {
            echo "550";
        }
    else{
            echo 550-550*($speed/11000);
        } 
        ?>"></td>
    </tr>
    </table>
   </td>
  </tr>
  </table>
  <?php echo (isset($_GET['speed']))?"Download 1000KB Used <font color='#cc0000'>".$_GET['speed']."</font> Millisecond, Download Speed："."<font color='#cc0000'>".$speed."</font>"." kb/s":"<font color='#cc0000'>&nbsp;Not Test&nbsp;</font>" ?>
    </td>
  </tr>
</table>

<a name="w_MySQL"></a>
<!--MySQL database Connection detection -->
<table>
  <tr><th colspan="3">MySQL Database connection detection</th></tr>

  <tr>
    <td width="15%"></td>
    <td width="60%">
      Host：<input type="text" name="host" value="localhost" size="10" />
      Port：<input type="text" name="port" value="3306" size="10" />
      Username：<input type="text" name="login" size="10" />
      Password：<input type="password" name="password" size="10" />
    </td>
    <td width="25%">
      <input class="btn" type="submit" name="act" value="MySQL Test" />
    </td>
  </tr>
</table>
<?php
  if (isset($_POST['act']) && $_POST['act'] == 'MySQL Test') {
      if(class_exists("mysqli")) {
	  
	  $link = new mysqli($host,$login,$password,'information_schema',$port);
          if ($link){
              echo "<script>alert('Connect to the MySql database to normal')</script>";
          } else {
              echo "<script>alert('Unable to connect to MySql database!')</script>";
          }
      } else {
          echo "<script>alert('Server does not support MySQL database!')</script>";
      }
  }
?>
    
<a name="w_function"></a>
<!-- function Test-->
<table>

  <tr><th colspan="3">Function Test</th></tr>

  <tr>
    <td width="15%"></td>
    <td width="60%">
      Enter the function you want to test: 
      <input type="text" name="funName" size="50" />
    </td>
    <td width="25%">
      <input class="btn" type="submit" name="act" align="right" value="Function Test" />
    </td>
  </tr>

<?php
  if (isset($_POST['act']) && $_POST['act'] == 'Function Test') {
      echo "<script>alert('$funRe')</script>";
  }
?>
</table>

<a name="w_mail"></a>
<!--Mail Send Test-->
<table>
  <tr><th colspan="3">Mail Send Test</th></tr>
  <tr>
    <td width="15%"></td>
    <td width="60%">
      Please enter your email address to test: 
      <input type="text" name="mailAdd" size="50" />
    </td>
    <td width="25%">
    <input class="btn" type="submit" name="act" value="Mail Test" />
    </td>
  </tr>
<?php
  if (isset($_POST['act']) && $_POST['act'] == 'Mail Test') {
      echo "<script>alert('$mailRe')</script>";
  }
?>
</table>
</form>
    <table>
        <tr>
            <td class="w_foot"><a href="https://lamp.sh" target="_blank">Based on YaHei.net probe</a></td>
            <td class="w_foot"><?php $run_time = sprintf('%0.4f', microtime_float() - $time_start);?>Processed in <?php echo $run_time?> seconds. <?php echo memory_usage();?> memory usage.</td>
            <td class="w_foot"><a href="#w_top">Back to top</a></td>
        </tr>
    </table>
</div>
</body>
</html>
