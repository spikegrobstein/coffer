module Coffer
  module Coin
    class Litecoin < Coffer::Definition
      git_branch 'master-0.8'
      git_repo 'https://github.com/litecoin-project/litecoin.git'
      home_page 'https://litecoin.org'
      symbol :LTC
      wallet_executable 'litecoind'
      directory 'Litecoin'
      config_file 'litecoin.conf'
    end
  end
end

binding.pry
