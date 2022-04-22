# Website Fingerprinting

Website fingerprinting is a method of passive traffic analysis that aims to collect enough features and information from individual sessions that could aid in identifying the activity of anonymized users.

## Introduction

Installing Dependencies:


``` bash
# For Debian based distributions
sudo apt install jq lynx

# For Fedora
sudo yum install jq lynx

# For ArchLinux
sudo pacman -S jq lynx
```

## Required Python 3 Modules

``` bash
python3 -m pip install sklearn dpkt joblib
```

## Data Collection

For the data collection process two terminal windows in a side-by-side orientation are required, as this process is fairly manual. Also, it's advised to collect the fingerprints in a VM, in order to avoid caputring any unintended traffic. To listen on traffic there exists a script, namely [capture.sh](./capture.sh), which should be run in one of the terminals:

``` bash
./capture.sh duckduckgo.com
```

Once the listener is capturing traffic, on the next terminal run:

``` bash
lynx https://duckduckgo.com
```

Once the website has finished loading, the capture process needs to be killed, along with the browser session (by hitting the `q` key twice). The process should be repeated several times for each web page so that there is enough data.

## Mass Data Collection

A bash scipt is provided to do a mass capture of website traffic, [mass-capture.sh](./mass-capture.sh). This differes from the above method in that it will automate the capturing process and reduce it to a single terminal session. mass-capture.sh will listen for traffic in the background and browse to the corresponding website by launching an instance of lynx. After 20 seconds, both are killed and the script moves on to the next capture. The script takes a single argument, the number of desired captures per domain. It should be run in the following way:

``` bash
./mass-capture.sh 15
```

## Machine Learning

[Scikit Learn](http://scikit-learn.org/stable/) was used to write a [k Nearest Neighbors](http://scikit-learn.org/stable/modules/neighbors.html#nearest-neighbors-classification) classifier, that would read the pcap files, as specified in the [config.json](config.json) file. `config.json` can be changed according to which webpages were targeted for training. The training script is [gather_and_train.py](gather_and_train.py).

<p align="center">
    <img src="http://scikit-learn.org/stable/_images/sphx_glr_plot_classification_0021.png" alt="Scikit Learn kNN" />
</p>

## Classifying Unknown Traffic

```bash
# python predict.py [packet to classify]
  python predict.py xyz.pcap
```
Once the training is done, and the `classifier-nb.dmp` is created, the [predict.py](predict.py) script can be run with the pcap file as the sole argument. The script will load the classifier and attempt to identify which web page the traffic originated from.

It is worth noting that from each sample only the first 40 packets will be used to train a usable model and to run through the resulting classifier.

## Limitations and Disclaimers

This setup was created in order to research the topic of website fingerprinting and how easy it is to attempt to deanonymize users over Tor or VPNs. Traffic was captured and identified in a private setting and for purely academic purposes; the use of this source code is intended for those reasons only.

Traffic is never "clean", as the assumption was - for simplicity - in this research. However, if an entity has enough resources, the desired anonymized traffic can be isolated and fed into this simple classifier. This means that it is entirely possible to use a method like this to compromise anonymized users.

## References

1. Wang, T. and Goldberg, I. (2017). Website Fingerprinting. [online] Cse.ust.hk. Available at: https://www.cse.ust.hk/~taow/wf/.
2. Wang, T. and Goldberg, I. (2017). Improved Website Fingerprinting on Tor. Cheriton School of Computer Science. Available at: http://www.cypherpunks.ca/~iang/pubs/webfingerprint-wpes.pdf
3. Wang, T. (2015). Website Fingerprinting: Attacks and Defenses. University of Waterloo. Available at: https://uwspace.uwaterloo.ca/bitstream/handle/10012/10123/Wang_Tao.pdf
