/**
 * SmartGuardian - AGC Function Contracts
 * Canonical contract catalog used by the frontend request layer and cloud-functions skeleton.
 */

import { ApiEndpoints } from '../../constants/ApiEndpoints';

export interface AgcFunctionContract {
  domain: string;
  functionName: string;
  routePrefixes: string[];
}

export const AGC_FUNCTION_CONTRACTS: AgcFunctionContract[] = [
  {
    domain: 'user',
    functionName: 'smartguardian-user',
    routePrefixes: [ApiEndpoints.USERS, ApiEndpoints.AUTH_ME]
  },
  {
    domain: 'auth',
    functionName: 'smartguardian-auth',
    routePrefixes: [
      ApiEndpoints.AUTH,
      ApiEndpoints.AUTH_LOGIN,
      ApiEndpoints.AUTH_LOGOUT,
      ApiEndpoints.AUTH_REFRESH,
      ApiEndpoints.AUTH_SESSION_DEVICE
    ]
  },
  {
    domain: 'student',
    functionName: 'smartguardian-student',
    routePrefixes: [ApiEndpoints.STUDENTS]
  },
  {
    domain: 'service',
    functionName: 'smartguardian-service',
    routePrefixes: [ApiEndpoints.SERVICE_PRODUCTS]
  },
  {
    domain: 'order',
    functionName: 'smartguardian-order',
    routePrefixes: [ApiEndpoints.ORDERS]
  },
  {
    domain: 'session',
    functionName: 'smartguardian-session',
    routePrefixes: [ApiEndpoints.SESSIONS]
  },
  {
    domain: 'attendance',
    functionName: 'smartguardian-attendance',
    routePrefixes: [ApiEndpoints.ATTENDANCE]
  },
  {
    domain: 'homework',
    functionName: 'smartguardian-homework',
    routePrefixes: [ApiEndpoints.HOMEWORK_TASKS, ApiEndpoints.HOMEWORK_FEEDBACK]
  },
  {
    domain: 'message',
    functionName: 'smartguardian-message',
    routePrefixes: [ApiEndpoints.MESSAGES]
  },
  {
    domain: 'report',
    functionName: 'smartguardian-report',
    routePrefixes: [ApiEndpoints.REPORTS]
  },
  {
    domain: 'refund',
    functionName: 'smartguardian-refund',
    routePrefixes: [ApiEndpoints.REFUNDS]
  },
  {
    domain: 'workbench',
    functionName: 'smartguardian-workbench',
    routePrefixes: [ApiEndpoints.WORKBENCH]
  },
  {
    domain: 'agent',
    functionName: 'smartguardian-agent',
    routePrefixes: [ApiEndpoints.AGENT]
  },
  {
    domain: 'security',
    functionName: 'smartguardian-security',
    routePrefixes: [ApiEndpoints.SECURITY]
  },
  {
    domain: 'event',
    functionName: 'smartguardian-event',
    routePrefixes: [ApiEndpoints.EVENTS]
  },
  {
    domain: 'notification',
    functionName: 'smartguardian-notification',
    routePrefixes: [ApiEndpoints.NOTIFICATIONS]
  },
  {
    domain: 'storage',
    functionName: 'smartguardian-storage',
    routePrefixes: [ApiEndpoints.STORAGE]
  },
  {
    domain: 'alert',
    functionName: 'smartguardian-alert',
    routePrefixes: [ApiEndpoints.ALERTS]
  },
  {
    domain: 'timeline',
    functionName: 'smartguardian-timeline',
    routePrefixes: [ApiEndpoints.TIMELINE]
  },
  {
    domain: 'card',
    functionName: 'smartguardian-card',
    routePrefixes: [ApiEndpoints.CARDS]
  },
  {
    domain: 'payment',
    functionName: 'smartguardian-payment',
    routePrefixes: [ApiEndpoints.PAYMENTS]
  }
];

export class AgcFunctionContractRegistry {
  static resolve(routePath: string): AgcFunctionContract {
    let matchedContract: AgcFunctionContract | null = null;
    let matchedPrefixLength = 0;

    for (let i = 0; i < AGC_FUNCTION_CONTRACTS.length; i++) {
      const contract = AGC_FUNCTION_CONTRACTS[i];
      for (let j = 0; j < contract.routePrefixes.length; j++) {
        const prefix = contract.routePrefixes[j];
        if (routePath === prefix || routePath.indexOf(`${prefix}/`) === 0) {
          if (prefix.length > matchedPrefixLength) {
            matchedContract = contract;
            matchedPrefixLength = prefix.length;
          }
        }
      }
    }

    if (matchedContract) {
      return matchedContract;
    }

    return {
      domain: 'gateway',
      functionName: 'smartguardian-gateway',
      routePrefixes: []
    };
  }
}
