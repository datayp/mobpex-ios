# start download channel SDKs
curl https://coding.net/u/jianhu/p/ChannelStore/git/archive/master > channel.zip

# unzip
unzip channel.zip > /dev/null

# move file to right directory
mv ChannelStore-master/channels libs

# clean
rm -rf ChannelStore-master channel.zip
