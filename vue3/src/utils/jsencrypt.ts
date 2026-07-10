import JSEncrypt from 'jsencrypt'

const publicKey = ''
const privateKey = ''

export function encrypt(data: string): string {
  const encryptor = new JSEncrypt()
  encryptor.setPublicKey(publicKey)
  return encryptor.encrypt(data)?.toString() || ''
}

export function decrypt(data: string): string {
  const decryptor = new JSEncrypt()
  decryptor.setPrivateKey(privateKey)
  return decryptor.decrypt(data)?.toString() || ''
}
