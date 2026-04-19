/**
 * SmartGuardian - Data Masking Utility
 * Data security and privacy protection for sensitive information
 */

/**
 * Data masking utility class for sensitive data protection
 */
export class DataMaskUtil {
  /**
   * Mask phone number: show first 3 and last 4 digits
   * Example: 13812345678 -> 138****5678
   */
  static maskPhone(phone: string | undefined): string {
    if (!phone || phone.length < 7) {
      return phone || '';
    }
    return phone.substring(0, 3) + '****' + phone.substring(phone.length - 4);
  }

  /**
   * Mask name: show only first character
   * Example: 张小明 -> 张**
   */
  static maskName(name: string | undefined): string {
    if (!name) {
      return '';
    }
    if (name.length <= 1) {
      return name;
    }
    return name.charAt(0) + '*'.repeat(name.length - 1);
  }

  /**
   * Mask ID card number: show first 6 and last 4 digits
   * Example: 110101199001011234 -> 110101********1234
   */
  static maskIdCard(idCard: string | undefined): string {
    if (!idCard || idCard.length < 10) {
      return idCard || '';
    }
    const front = idCard.substring(0, 6);
    const back = idCard.substring(idCard.length - 4);
    const middle = '*'.repeat(idCard.length - 10);
    return front + middle + back;
  }

  /**
   * Mask bank card number: show first 4 and last 4 digits
   * Example: 6222021234567890 -> 6222****7890
   */
  static maskBankCard(cardNo: string | undefined): string {
    if (!cardNo || cardNo.length < 8) {
      return cardNo || '';
    }
    const front = cardNo.substring(0, 4);
    const back = cardNo.substring(cardNo.length - 4);
    return front + '****' + back;
  }

  /**
   * Mask email: show first 2 characters before @
   * Example: testuser@example.com -> te*****@example.com
   */
  static maskEmail(email: string | undefined): string {
    if (!email || !email.includes('@')) {
      return email || '';
    }
    const parts = email.split('@');
    const name = parts[0];
    const domain = parts[1];
    
    if (name.length <= 2) {
      return name[0] + '***@' + domain;
    }
    
    return name.substring(0, 2) + '***@' + domain;
  }

  /**
   * Mask address: show only province and city
   * Example: 北京市朝阳区某某街道某某小区 -> 北京市朝阳区***
   */
  static maskAddress(address: string | undefined, showLength: number = 6): string {
    if (!address) {
      return '';
    }
    if (address.length <= showLength) {
      return address;
    }
    return address.substring(0, showLength) + '***';
  }

  /**
   * Mask student number: show only last 4 digits
   * Example: S202401001 -> ******0001
   */
  static maskStudentNo(studentNo: string | undefined): string {
    if (!studentNo || studentNo.length < 4) {
      return studentNo || '';
    }
    return '*'.repeat(studentNo.length - 4) + studentNo.substring(studentNo.length - 4);
  }

  /**
   * Auto-detect and mask based on data type
   */
  static autoMask(data: string | undefined, type: 'phone' | 'name' | 'idCard' | 'email' | 'bankCard' | 'address'): string {
    switch (type) {
      case 'phone':
        return this.maskPhone(data);
      case 'name':
        return this.maskName(data);
      case 'idCard':
        return this.maskIdCard(data);
      case 'email':
        return this.maskEmail(data);
      case 'bankCard':
        return this.maskBankCard(data);
      case 'address':
        return this.maskAddress(data);
      default:
        return data || '';
    }
  }
}
