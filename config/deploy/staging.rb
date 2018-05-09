set :stage, :production

server "konnektlive.com", user: "deployer", roles: %w{app db web}
set :nginx_server_name, "staging.konnektlive.com"
set :nginx_domains, "staging.konnektlive.com"
