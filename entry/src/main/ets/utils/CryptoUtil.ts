/**
 * SmartGuardian - Cryptography Utility
 * Encryption, decryption, and hashing utilities for data security
 * Note: Using simplified implementation for broad compatibility
 */

// Logger utility not available in TS files, using console

/**
 * Cryptography utility for data encryption and hashing
 */
export class CryptoUtil {
  private static readonly TAG = 'CryptoUtil';
  private static readonly AES_KEY = 'SmartGuardian2026SecretKey'; // 32 bytes for AES-256

  /**
   * AES-like encryption for sensitive data (simplified)
   * Uses simple XOR encoding for demonstration
   * In production, use @ohos.security.cryptoFramework for proper AES encryption
   * 
   * @param plainText - text to encrypt
   * @param key - encryption key (optional)
   * @returns encrypted base64 string
   */
  static encryptSimple(plainText: string, key?: string): string {
    try {
      const keyStr = key || this.AES_KEY;
      const keyChars = keyStr.split('');
      const plainChars = plainText.split('');
      
      const encryptedChars: string[] = [];
      for (let i = 0; i < plainChars.length; i++) {
        const keyChar = keyChars[i % keyChars.length];
        const encryptedChar = String.fromCharCode(plainChars[i].charCodeAt(0) ^ keyChar.charCodeAt(0));
        encryptedChars.push(encryptedChar);
      }
      
      return this.base64Encode(encryptedChars.join(''));
    } catch (error) {
      console.error(`[${this.TAG}] encryptSimple failed: ${JSON.stringify(error)}`);
      return this.base64Encode(plainText);
    }
  }

  /**
   * AES-like decryption for sensitive data (simplified)
   * Uses simple XOR decoding for demonstration
   * 
   * @param cipherText - base64 encrypted text
   * @param key - decryption key (optional)
   * @returns decrypted plain text
   */
  static decryptSimple(cipherText: string, key?: string): string {
    try {
      const keyStr = key || this.AES_KEY;
      const encryptedText = this.base64Decode(cipherText);
      
      const keyChars = keyStr.split('');
      const encryptedChars = encryptedText.split('');
      
      const decryptedChars: string[] = [];
      for (let i = 0; i < encryptedChars.length; i++) {
        const keyChar = keyChars[i % keyChars.length];
        const decryptedChar = String.fromCharCode(encryptedChars[i].charCodeAt(0) ^ keyChar.charCodeAt(0));
        decryptedChars.push(decryptedChar);
      }
      
      return decryptedChars.join('');
    } catch (error) {
      console.error(`[${this.TAG}] decryptSimple failed: ${JSON.stringify(error)}`);
      return this.base64Decode(cipherText);
    }
  }

  /**
   * MD5-like hash function (simplified)
   * In production, use @ohos.security.cryptoFramework.md()
   * 
   * @param input - string to hash
   * @returns hash string
   */
  static simpleHash(input: string): string {
    let hash = 0;
    for (let i = 0; i < input.length; i++) {
      const char = input.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32bit integer
    }
    return Math.abs(hash).toString(16).padStart(8, '0');
  }

  /**
   * SHA256-like hash (use md5-like implementation for demo)
   */
  static async hashPassword(password: string): Promise<string> {
    // Add salt
    const salt = 'SmartGuardian_Salt_2026';
    const saltedPassword = password + salt;
    
    // Simple hash multiple rounds
    let hash = this.simpleHash(saltedPassword);
    for (let i = 0; i < 1000; i++) {
      hash = this.simpleHash(hash + salt);
    }
    
    return hash;
  }

  /**
   * Verify password hash
   */
  static async verifyPassword(password: string, hash: string): Promise<boolean> {
    const newHash = await this.hashPassword(password);
    return newHash === hash;
  }

  /**
   * Base64 encode
   */
  static base64Encode(input: string): string {
    try {
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
      let result = '';
      let i = 0;
      
      while (i < input.length) {
        const byte1 = input.charCodeAt(i++);
        const byte2 = i < input.length ? input.charCodeAt(i++) : 0;
        const byte3 = i < input.length ? input.charCodeAt(i++) : 0;
        
        const triplet = (byte1 << 16) | (byte2 << 8) | byte3;
        
        result += chars[(triplet >> 18) & 0x3F];
        result += chars[(triplet >> 12) & 0x3F];
        result += i > input.length + 1 ? '=' : chars[(triplet >> 6) & 0x3F];
        result += i > input.length ? '=' : chars[triplet & 0x3F];
      }
      
      return result;
    } catch (error) {
      console.error(`[${this.TAG}] base64Encode failed: ${JSON.stringify(error)}`);
      return input;
    }
  }

  /**
   * Base64 decode
   */
  static base64Decode(input: string): string {
    try {
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
      let result = '';
      let i = 0;
      
      input = input.replace(/[^A-Za-z0-9\+\/\=]/g, '');
      
      while (i < input.length) {
        const byte1 = chars.indexOf(input.charAt(i++));
        const byte2 = chars.indexOf(input.charAt(i++));
        const byte3 = chars.indexOf(input.charAt(i++));
        const byte4 = chars.indexOf(input.charAt(i++));
        
        const triplet = (byte1 << 18) | (byte2 << 12) | (byte3 << 6) | byte4;
        
        result += String.fromCharCode((triplet >> 16) & 0xFF);
        if (byte3 !== 64) {
          result += String.fromCharCode((triplet >> 8) & 0xFF);
        }
        if (byte4 !== 64) {
          result += String.fromCharCode(triplet & 0xFF);
        }
      }
      
      return result;
    } catch (error) {
      console.error(`[${this.TAG}] base64Decode failed: ${JSON.stringify(error)}`);
      return input;
    }
  }

  /**
   * Generate random string
   * @param length - length of random string
   * @returns random string
   */
  static generateRandomString(length: number = 16): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }

  /**
   * Generate random number
   * @param min - minimum value
   * @param max - maximum value
   * @returns random number
   */
  static generateRandomNumber(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  /**
   * Generate token for API authentication
   */
  static generateToken(): string {
    const timestamp = Date.now().toString();
    const random = this.generateRandomString(16);
    return this.base64Encode(`${timestamp}_${random}`);
  }

  /**
   * Verify token expiration (tokens expire in 24 hours)
   */
  static isTokenExpired(token: string): boolean {
    try {
      const decoded = this.base64Decode(token);
      const timestamp = parseInt(decoded.split('_')[0]);
      const now = Date.now();
      const twentyFourHours = 24 * 60 * 60 * 1000;
      return (now - timestamp) > twentyFourHours;
    } catch (error) {
      return true;
    }
  }

  /**
   * Encrypt sensitive data before transmission
   */
  static encryptForTransmission(data: string): string {
    return this.encryptSimple(data);
  }

  /**
   * Decrypt received sensitive data
   */
  static decryptFromTransmission(data: string): string {
    return this.decryptSimple(data);
  }
}
