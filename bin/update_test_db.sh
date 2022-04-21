echo "drop database firemind_test;" | sudo mysql
echo "create database firemind_test DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" | sudo mysql
sudo mysql firemind_test < test/base.sql
bin/rails db:migrate RAILS_ENV=test
sudo mysqldump firemind_test > test/base.sql
