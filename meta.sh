#!/data/data/com.termux/files/usr/bin/bash
clear

# Hollywood-Style ASCII Header
echo -e "\033[1;31m"
cat << "EOF"

███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗              ███████╗██████╗  ██████╗ ██╗██╗     ███████╗██████╗ 
██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║              ██╔════╝██╔══██╗██╔═══██╗██║██║     ██╔════╝██╔══██╗
███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║    █████╗    ███████╗██████╔╝██║   ██║██║██║     █████╗  ██████╔╝
╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║    ╚════╝    ╚════██║██╔═══╝ ██║   ██║██║██║     ██╔══╝  ██╔══██╗
███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║              ███████║██║     ╚██████╔╝██║███████╗███████╗██║  ██║
╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝              ╚══════╝╚═╝      ╚═════╝ ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝
                                                                                                                       

EOF
echo -e "\033[0m"
echo -e "\033[1;32m                      By SYSTEM SPOILER                     \033[0m"

# Function to center text with padding
center() {
  termwidth=$(stty size | cut -d" " -f2)
  padding="$(printf '%0.1s' ={1..500})"
  printf '%*.*s %s %*.*s\n' 0 "$(((termwidth-2-${#1})/2))" "$padding" "$1" 0 "$(((termwidth-1-${#1})/2))" "$padding"
}

# Loading Spinner
center " Initiating System..."
spinner() {
  chars="/-\|"
  while :; do
    for char in $chars; do
      echo -ne "\r\033[1;36m[*] Loading... $char \033[0m"
      sleep 0.1
    done
  done
}

spinner &  # Run spinner in the background
SPINNER_PID=$!
trap "kill $SPINNER_PID" EXIT

# Simulated delay for dramatic effect
sleep 3
kill $SPINNER_PID
trap - EXIT
echo -e "\n\033[1;32m[*] System Ready!\033[0m"
sleep 1

# Dependencies installation
echo
center "*** Installing Dependencies ***"
pkg upgrade -y -o Dpkg::Options::="--force-confnew"

pkg install -y binutils python autoconf bison clang coreutils curl findutils apr apr-util postgresql openssl readline libffi libgmp libpcap libsqlite libgrpc libtool libxml2 libxslt ncurses make ncurses-utils ncurses git wget unzip zip tar termux-tools termux-elf-cleaner pkg-config git ruby python-pip -o Dpkg::Options::="--force-confnew"

python3 -m pip install --upgrade pip
python3 -m pip install requests

# Ruby BigDecimal Fix
echo
center "*** Fixing Ruby BigDecimal ***"
source <(curl -sL https://github.com/termux/termux-packages/files/2912002/fix-ruby-bigdecimal.sh.txt)

# Metasploit download and install
echo
center "*** Downloading Metasploit Framework ***"
cd /data/data/com.termux/files/home
git clone https://github.com/rapid7/metasploit-framework.git --depth=1

echo
center "*** Installing Metasploit Framework ***"
cd /data/data/com.termux/files/home/metasploit-framework
sed -i 's/nio4r (2.5.8)/nio4r (2.5.9)/' Gemfile.lock

gem install bundler
bundle config build.nokogiri --use-system-libraries

# List of required gems for Metasploit
gems=(
  puma:6.1.0
  activesupport:7.0.6.1
  activerecord:7.0.6.1
  nokogiri
  rex
  metasploit_payloads
  metasploit-aggregator
  json
)

# Install required gems
for gem in "${gems[@]}"; do
  IFS=":" read -r name version <<< "$gem"
  if [ -z "$version" ]; then
    gem install "$name" --no-document
  else
    gem install "$name" --version "$version" --no-document
  fi
done

# Bundle install with all gems
bundle install -j$(nproc --all)

# Fix warnings and errors
echo
center "*** Suppressing Warnings ***"
termux-elf-cleaner $PREFIX/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so

# Create symlinks for convenience
ln -sf /data/data/com.termux/files/home/metasploit-framework/msfconsole $PREFIX/bin/
ln -sf /data/data/com.termux/files/home/metasploit-framework/msfvenom $PREFIX/bin/
ln -sf /data/data/com.termux/files/home/metasploit-framework/msfrpcd $PREFIX/bin/

# Completion message
echo
center "*"
echo -e "\033[1;32m Installation Complete! \033[0m"
center "*"
echo -e "\033[1;36m Launch Metasploit with: msfconsole \033[0m"
