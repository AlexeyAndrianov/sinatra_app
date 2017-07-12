require 'jwt'

payload = {:data => @user_id}

rsa_private = OpenSSL::PKey::RSA.generate 2048
rsa_public = rsa_private.public_key

token = JWT.encode payload, rsa_private, 'RS256'

# eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJ0ZXN0IjoiZGF0YSJ9.c2FynXNyi6_PeKxrDGxfS3OLwQ8lTDbWBWdq7oMviCy2ZfFpzvW2E_odCWJrbLof-eplHCsKzW7MGAntHMALXgclm_Cs9i2Exi6BZHzpr9suYkrhIjwqV1tCgMBCQpdeMwIq6SyKVjgH3L51ivIt0-GDDPDH1Rcut3jRQzp3Q35bg3tcI2iVg7t3Msvl9QrxXAdYNFiS5KXH22aJZ8X_O2HgqVYBXfSB1ygTYUmKTIIyLbntPQ7R22rFko1knGWOgQCoYXwbtpuKRZVFrxX958L2gUWgb4jEQNf3fhOtkBm1mJpj-7BGst00o8g_3P2zHy-3aKgpPo1XlKQGjRrrxA
puts token

decoded_token = JWT.decode token, rsa_public, true, { :algorithm => 'RS256' }

# Array
# [
#   {"data"=>"test"}, # payload
#   {"alg"=>"RS256"} # header
# ]
puts decoded_token

