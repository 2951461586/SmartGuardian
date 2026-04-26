export enum LayoutSizeClass {
  COMPACT = 'COMPACT',
  MEDIUM = 'MEDIUM',
  EXPANDED = 'EXPANDED'
}

export class LayoutBreakpoints {
  static readonly MEDIUM: number = 680;
  static readonly EXPANDED: number = 980;
  static readonly MAX_CONTENT_COMPACT: number = 560;
  static readonly MAX_CONTENT_REGULAR: number = 860;
  static readonly MAX_CONTENT_WIDE: number = 1180;
}

export function resolveLayoutSizeClass(width: number): LayoutSizeClass {
  if (width >= LayoutBreakpoints.EXPANDED) {
    return LayoutSizeClass.EXPANDED;
  }
  if (width >= LayoutBreakpoints.MEDIUM) {
    return LayoutSizeClass.MEDIUM;
  }
  return LayoutSizeClass.COMPACT;
}

export function resolvePageSidePadding(width: number): number {
  const sizeClass = resolveLayoutSizeClass(width);
  if (sizeClass === LayoutSizeClass.EXPANDED) {
    return 28;
  }
  if (sizeClass === LayoutSizeClass.MEDIUM) {
    return 22;
  }
  return 16;
}

export function resolvePageMaxWidth(width: number, enableWide: boolean = false): number {
  const sizeClass = resolveLayoutSizeClass(width);
  if (enableWide && sizeClass === LayoutSizeClass.EXPANDED) {
    return LayoutBreakpoints.MAX_CONTENT_WIDE;
  }
  if (sizeClass === LayoutSizeClass.EXPANDED) {
    return LayoutBreakpoints.MAX_CONTENT_REGULAR;
  }
  return LayoutBreakpoints.MAX_CONTENT_COMPACT;
}

export function shouldUseSplitLayout(width: number): boolean {
  return resolveLayoutSizeClass(width) !== LayoutSizeClass.COMPACT;
}
