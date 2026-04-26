/**
 * SmartGuardian - Lazy Array Data Source
 * Shared IDataSource implementation for LazyForEach based list rendering.
 */

export class LazyArrayDataSource<T> implements IDataSource {
  private items: T[] = [];
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.items.length;
  }

  getData(index: number): T {
    return this.items[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.containsListener(listener)) {
      return;
    }
    this.listeners.push(listener);
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.findListenerIndex(listener);
    if (index < 0) {
      return;
    }
    this.listeners.splice(index, 1);
  }

  setItems(items: T[]): void {
    this.items = items.slice();
    this.notifyReloaded();
  }

  clear(): void {
    this.items = [];
    this.notifyReloaded();
  }

  private notifyReloaded(): void {
    for (let i = 0; i < this.listeners.length; i++) {
      this.listeners[i].onDataReloaded();
    }
  }

  private containsListener(listener: DataChangeListener): boolean {
    return this.findListenerIndex(listener) >= 0;
  }

  private findListenerIndex(listener: DataChangeListener): number {
    for (let i = 0; i < this.listeners.length; i++) {
      if (this.listeners[i] === listener) {
        return i;
      }
    }
    return -1;
  }
}
