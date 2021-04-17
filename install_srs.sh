# update system
sudo apt-get update
sudo apt-get -y upgrade

# install dependencies
sudo apt-get -y install git build-essential libssl-dev python

# download srs
if [ -d "./srs" ]
then
	echo "srs already exists"
else
	echo "clone srs..."
	git clone https://github.com/ossrs/srs.git
fi


pushd srs/trunk
./configure --full --use-sys-ssl --without-utest
make
sudo make install


# create autostart script
sudo ln -sf /usr/local/srs/etc/init.d/srs /etc/init.d/srs
sudo cp -f /usr/local/srs/usr/lib/systemd/system/srs.service /usr/lib/systemd/system/srs.service
sudo systemctl daemon-reload
sudo systemctl enable srs
sudo systemctl start srs

# logrotate 
sudo touch /etc/logrotate.d/srs
sudo bash -c 'cat > /etc/logrotate.d/srs' << EOF 
/usr/local/srs/objs/srs.log
{ 
        daily 
        missingok 
        rotate 6 
        compress 
        notifempty 
        create 664 root 
        sharedscripts 
        postrotate 
                [ -f /usr/local/srs/objs/srs.pid ] && kill -USR1 \`cat /usr/local/srs/objs/srs.pid\`
        endscript 
} 
EOF

# modify logrotate.service
echo "ReadWritePaths=/usr/local/nginx/logs /usr/local/srs/objs" >> /lib/systemd/system/logrotate.service

popd
rm -rf srs
echo "srs install finish."
