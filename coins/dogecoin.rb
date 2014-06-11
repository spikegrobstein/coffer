# May have issues

module Coffer
  module Coin
    class Dogecoin < Coffer::Definition
      git_repo 'https://github.com/dogecoin/dogecoin.git'
      home_page 'http://dogecoin.com'
      symbol :DOGE
      wallet_executable 'dogecoind'
      directory 'dogecoin'
      config_file 'dogecoin.conf'

      build <<-BUILD
        ./autogen.sh
        ./configure --with-incompatible-bdb
        make
      BUILD

      build_dir '/'
    end
  end
end
