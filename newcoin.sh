#! /bin/bash -

echo "Creating new coin..."

read -p "Name: " COIN_NAME
read -p "Git repo: " GIT_REPO
read -p "Homepage: " HOME_PAGE
read -p "Symbol:   " SYMBOL
read -p "Wallet executable: " WALLET_EXECUTABLE
read -p "Directory: " DIRECTORY
read -p "Config file: " CONFIG_FILE

FILENAME=$( echo $COIN_NAME | tr '[:upper:]' '[:lower:]' )

cat > coins/${FILENAME}.rb <<EOF
module Coffer
  module Coin
    class ${COIN_NAME} < Coffer::Definition
      git_repo '${GIT_REPO}'
      home_page '${HOME_PAGE}'
      symbol :${SYMBOL}
      wallet_executable '${WALLET_EXECUTABLE}'
      directory '${COIN_NAME}'
      config_file '${CONFIG_FILE}'
    end
  end
end
EOF
