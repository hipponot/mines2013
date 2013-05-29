!/bin/bash

ruby extconf.rb
make clean
make
cp eq_ocr.so /vagrant/eq_ocr/lib/eq_ocr.so