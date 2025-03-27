# Flow-based Monitoring with TDC-X

Real-time sensor data monitoring system using MPB10 Multi Physics Box sensor and TDC-X device. Features flow-based architecture with Node-RED, MQTT, InfluxDB and Grafana.

## Overview

This application creates a complete monitoring pipeline for industrial sensor data:
- Real-time data collection from MPB10 sensor (vibration, shock, temperature)
- IO-Link communication via TDC-X device
- MQTT messaging for data transmission
- Data processing with Node-RED
- Time-series storage in InfluxDB 
- Real-time visualization in Grafana

## System Architecture
```mermaid
graph LR
    MPB[MPB10 Sensor] --> |IO-Link| TDC[TDC-X]
    TDC -->|MQTT| NR[Node-RED]
    NR -->|Write API| IDB[InfluxDB]
    IDB -->|Query API| G[Grafana]
```

## Contents

1. [Description](#overview)
2. [System Architecture](#system-architecture)
3. [System Requirements](#system-requirements)
   - [Hardware Requirements](#hardware)
   - [Software Requirements](#software)
4. [TDC-X Information](#tdx-x-information)
   - [Network Configuration](#network-configuration)
   - [Access Methods](#access-methods)
   - [Required Ports](#required-ports)
5. [Quick Start](#quick-start)
6. [Setup Instructions](#setup-instructions)
   - [Application Installation](#application-installation)
   - [MPB10 Sensor Setup](#mpb10-sensor-setup)
   - [MQTT Configuration](#mqtt-setup)
7. [Application Setup](#application-setup)
   - [Application Overview](#application-overview)
   - [Installation Verification](#installation-verification)
   - [InfluxDB Configuration](#influxdb)
   - [Node-RED Configuration](#node-red)
   - [Grafana Configuration](#grafana)
8. [Data Formats](#data-formats)
   - [JSON Structures](#json-structure)
9. [Dashboard Configuration](#dashboard-configuration)
   - [InfluxDB Dashboard](#influxdb-dashboard-configuration)
   - [Grafana Dashboard](#grafana)
10. [Troubleshooting](#troubleshooting)


## System Requirements

Hardware:
- MPB10 Multi Physics Box sensor
- TDC-X device, firmware version: 1.2.0 or higher
- Network connection

Software:
- Node-RED (port 1880)
- InfluxDB (port 8086) 
- Grafana (port 3000)
- Mosquitto MQTT broker

## Troubleshooting

Common issues and solutions:

- **MQTT Connection Failed**: Verify Mosquitto broker is running and credentials are correct
- **InfluxDB Write Errors**: Check API token permissions and bucket exists
- **No Data in Grafana**: Verify InfluxDB data source configuration and query syntax
- **Missing Sensor Data**: Check IO-Link connection and MQTT topic configuration

### TDC-X Network Configuration
- IP Address: **192.168.0.100**
- Web Interface Port: 80
- Default Gateway: 192.168.0.1
- Subnet Mask: 255.255.255.0

## Quick Start
1. Install required applications on TDC-X (Node-RED, InfluxDB, Grafana, Mosquitto)
2. Configure MPB10 sensor and IO-Link connection
3. Set up MQTT messaging
4. Import Node-RED flows
5. Configure InfluxDB storage
6. Import Grafana dashboards

### Application installation
In this example, following applications will be used: **NodeRed**, **Grafana**, **InfluxDB** and **Mosquitto**. To install the apps, simply aim to applications tab to find list of applications. Next to application needed, **install** button can be found.

_**NOTE:** To install the listed applications, make sure the TDC-X device is connected to a network._

For detailed guide how to install apps please visit: [Installing, Accessing and Removing Applications](https://github.com/SICKAG/sick_tdc-x-developers-documentation/wiki/Getting-Started#installing-accessing-and-removing-applications)


### MPB10  sensor setup
The Multi Physics Box MPB10 is a condition monitoring sensor. It is used to detect ambient and/or status conditions of a machine or system, such as vibration, shock and temperature. More information about the sensor you can find [here](https://www.sick.com/be/en/catalog/products/detection-sensors/condition-monitoring-sensors/multi-physics-box/mpb10-vs00vsiq00/p/p670770).

#### Connect MPB10 to TDC-X
Make sure that sensor is plugged to your TDC-X device which has multiple interfaces for IO-Link devices, we are assuming that you connected it to port 1. Now if you click [this](http://192.168.0.100/#/io-link/devices/1) link you should be able to see device that is connected to your TDC-X.

#### IODD file
IODD XML file is describing how IO-Link devices communicate information to higher level systems or controllers. For needed .xml file use IODD finder to download it [here](https://ioddfinder.io-link.com/productvariants/search/42370). 

#### IODD file upload on TDC-X

Go to IO-Link tab and open IODD File Management, you can find it [here](http://192.168.0.100/#/io-link/iodd-file-management). Simply click upload and choose the file you need.

![iodd_file_management](/application-examples/Flow-Based-Monitoring/img/iodd_file_upload.png)
This is how your screen should look like after uploading the file correctly.

_**NOTE:** To download the file, make sure you read [this](#iodd-file) section._

Now if you head back to IO-Link tab ([link](http://192.168.0.100/#/io-link/devices/1)) and click IODD view, much more detailed and profiled data will be shown.

![iodd view](/application-examples/Flow-Based-Monitoring/img/iodd_view.png)
This is how screen should look like after clicking IODD view.

### MQTT setup

_**NOTE:** Before working with MQTT make sure you have **Mosquitto** application installed._


Go to IO-Link tab and find MQTT settings ([link](http://192.168.0.100/#/io-link/MQTT-settings)) and under MQTT configuration section set Client mode active **true** and fill required fields.

#### MQTT configuration fields:
* **Server IP:** 192.168.0.100

_**NOTE:** For this project we use mosquitto broker on TDC-X, so **Server IP** is TDC-X IP address._
* **Port:** 1883
* **Username:** admin
* **Password:** password


_**NOTE:**  Default configuration of internal broker requires no **Username** and **password**._
* **Keep alive time:** 60



![MQTT configuration](/application-examples/Flow-Based-Monitoring/img/mqtt_configuration.png)

#### Last will settings:
* **Topic:** lastWillTopic
* **Message:** last will message
* **QoS:** Only Once
* **Retain:** false

![last will settings](/application-examples/Flow-Based-Monitoring/img/last_will_settings.png)

#### MQTT status:
If everything is set up correctly under MQTT status connection, once settings are applies, status connection should be accepted.

![MQTT status](/application-examples/Flow-Based-Monitoring/img/mqtt_status.png)

### Send IO-Link data to broker:
To send data from IO-Link device to broker we have to configure MQTT topics section in IO-Link tab ([link](http://192.168.0.100/#/io-link/MQTT-settings)). 

#### MQTT topics:
Press **Add topic** button and fill required fields
* **Port:** Port 1
* **QoS:** Only Once
* **Type:** Process data
* **Direction:** Get data
* **Format:** Iodd data
* **Interval:** Interval
* **Cycle time:** 1000
* **Topic name:** master1port1/processData

If everything is set up correctly under MQTT topics you should see this.
![MQTT topics](/application-examples/Flow-Based-Monitoring/img/mqtt_topics.png)


This section covers the setup and configuration of all required applications for the monitoring system. Make sure you have the following applications installed and running:

### Application Overview
1. **Node-RED** (port 1880)
   - Data flow orchestration and processing
   - MQTT subscriber and publisher
   - Data transformation for InfluxDB

2. **InfluxDB** (port 8086)
   - Time-series database for sensor data storage
   - API endpoint for data ingestion
   - Built-in dashboard capabilities

3. **Grafana** (port 3000)
   - Advanced data visualization
   - Real-time monitoring dashboards
   - Multi-source data integration

4. **Mosquitto** (port 1883)
   - MQTT message broker
   - Handles pub/sub communication
   - Connects TDC-X to Node-RED

#### Installation Verification
Before proceeding with configuration, verify that:
- All applications are installed on TDC-X
- Required ports are accessible
- Applications show "Running" status in TDC-X interface
- Network connectivity is established

For detailed installation instructions, refer to the [Application Installation Guide](#application-installation).


### InfluxDB 

InfluxDB is the time series data platform designed to handle high write and query workloads.
Make sure to install it using **Applications** tab, after that you can access its UI on port **8086**. 

#### Configuration

![influx initial user](/application-examples/Flow-Based-Monitoring/img/influx_initial_user.png)
Picture shows how the Initial User is configured for this example.


Enter preferred username, password, organization name and bucket name. ***Bucket*** is where your time series data is stored with a retention policy.

_**NOTE:** **READ THIS PART.**_
After initial user setup API token will be shown.
This part is really important because you won't be able to see token after you continue, so copy the token and save it somewhere local in Notepad++ or any other text processor you use. 

### Node-Red 
Low-code programming for event-driven applications.
Make sure to install it using **Applications** tab, after that you can access its UI on port **1880**. 

#### Configuration
This section will explain how to setup and configure node-red.

##### Flow import 

* Find and click on burger bar (top right corner). 

![node-red burger](/application-examples/Flow-Based-Monitoring/img/node-red_burger.png)

* Click import.

![node-red import](/application-examples/Flow-Based-Monitoring/img/node-red_import.png)

* Paste the JSON configuration available [here](/application-examples/Flow-Based-Monitoring/src/nodered_flow.json) and click import.

![import nodes](/application-examples/Flow-Based-Monitoring/img/import_nodes.png)

* Flow should be present as on picture

![Imported flow](/application-examples/Flow-Based-Monitoring/img/node-red_main_flow.png)

##### Credentials

Make sure to insert credentials to authenticate for TDC-X API calls.

* Double-click on ***credentials***

![credentials node](/application-examples/Flow-Based-Monitoring/img/node-red_credentials_node.png)

* Change ***tdcx-username*** and ***tdcx-password*** to credentials used for your TDC-X device.

![change tdcx credentials](/application-examples/Flow-Based-Monitoring/img/node-red_credentials.png)


##### HTTP requests

TDC-X group is connecting to TDC-X REST API to authenticate and get TDC-X and MPB data. Device endpoints can be accessed [here](http://192.168.0.100/docs/control-center/).

**NOTE:** Follow steps below only if your IP address is not default (192.168.0.100)

* Open ***tdc-x stats endpoint*** node.

![node-red stats endpoint ](/application-examples/Flow-Based-Monitoring/img/node-red_stats_node.png)

* Change IP address that suits device.

![tdc-x stats endpoint](/application-examples/Flow-Based-Monitoring/img/tdc-x_stats_link.png)
* Open ***tdc-x auth endpoint*** node.

![node-red auth endpoint ](/application-examples/Flow-Based-Monitoring/img/node-red_auth_node.png)

* Again change IP address that suits device.

![tdc-x auth endpoint](/application-examples/Flow-Based-Monitoring/img/tdc-x_auth_link.png)

* Open ***influxdb-write*** node.

![node-red influx endpoint](/application-examples/Flow-Based-Monitoring/img/node-red_influxdb_write_node.png)

* Change IP address based on your InfluxDB configuration, InfluxDB API is explained [here](#influxdb-endpoint)

![influxdb write endpoint](/application-examples/Flow-Based-Monitoring/img/node-red_influxdb_write.png)

* Check ***Use authentication***, type is ***bearer*** and under ***token*** field insert your InfluxDB token.

![influxdb write auth](/application-examples/Flow-Based-Monitoring/img/node-red_influxdb_auth.png)

###### InfluxDB endpoint

From official API [documentation](https://docs.influxdata.com/influxdb/v1/guides/write_data/) writing to a database using the InfluxDB 2.0 API (compatible with InfluxDB 1.8+) can be achieved by sending POST requests to the /api/v2/write endpoint:

```
curl -i -XPOST 'http://localhost:8086/api/v2/write?bucket=db/rp&precision=ns' \
  --header 'Authorization: Token username:password' \
  --data-raw 'cpu_load_short,host=server01,region=us-west value=0.64 1434055562000000000'
```

Endpoint URL should be:
```
http://{DEVICE_IP}:8086/api/v2/write?org=<influxdb organisation name>&bucket={<influxdb bucket name>}&precision=ms 
```

#### Start Application

To start node-red flow press red ***Deploy*** button on top right side of the screen.

#### JSON structure. 
This section shows parsed data that flows to InfluxDB.

**TDC-X monitor data:**
```
{
  "measurement": "mpb",
  "tags": {
    "host": "server01",
    "region": "eu"
  },
  "fields": {
    "cpu_load": 0.72,
    "memory_used": 765.0,
    "temperature1": 43,
    "temperature2": 46.75
  }
}
```

**MPB sensor data:**
```
{
  "measurement": "mpb",
  "tags": {
    "host": "server01",
    "region": "eu"
  },
  "fields": {
    "value_x": 24,
    "value_y": 43,
    "value_z": 15
  }
}
```

 


### InfluxDB Dashboard configuration 

InfluxDB also offers very quick dashboard configuration so one will be demonstrated here. Access InfluxDB UI on port 8086, go to Dashboards tab and click on **create dashboard** button, choose new dashboard, then click on **add cell**.

Instead of creating new one, you can import the dashboard created for this example, download it from [here](/application-examples/Flow-Based-Monitoring/src/influxdb_dashboard.json). For this example we will use Gauge chart which will nicely represent x, y and z values.


![cell editing](/application-examples/Flow-Based-Monitoring/img/cell-setup.png)

In the left corner under queries choose the source (bucket) and then you can filter the data based on the JSON file inserted into it. Multiple filters can be applied, since speedometer will be demonstrated then three separated gauges will be created for each value. Dashboard should look like picture down below if steps were followed correctly.

![dashboard setup](/application-examples/Flow-Based-Monitoring/img/dashboard-setup.png)

**NOTE:** Refreshing interval can be changed to 1s by clicking on refresh button and hardcore type the 1s value.

### Grafana 

Grafana Cloud is a highly available, fast, fully-managed OpenSaaS logging, metrics, traces, and profiling platform that also provides incident management and our application monitoring service.
Make sure to install it using **Applications** tab, after that you can access its UI on port **3000**. 

#### Setup

To access data from influxd, **data source** has to be created. Go to **connections** and **Data sources**, then choose **InfluxDB** as a source.

Look at the picture down below for guidance how to setup datasource, make sure to check your TDC-X IP address.

![influxdb data source in grafana](/application-examples/Flow-Based-Monitoring/img/grafana_influxdb_source.png)

Created data source gives you many possibilities to create various dashboards and graphs in Grafana.  

![dashboard in grafana](/application-examples/Flow-Based-Monitoring/img/grafana_dashboard.png)

Dashboard created for this demonstration purposes, shows MPB sensor data and TDC-X monitoring data.

Grafana dashboard import files are available [here](/application-examples/Flow-Based-Monitoring/src/grafana_dashboard.json). If you want to use them go to **Dashboards → New → import**, then simply paste the JSON code or load the JSON file.