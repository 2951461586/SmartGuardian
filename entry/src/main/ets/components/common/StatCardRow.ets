import { StatCard } from './Card';

export interface StatRowItem {
  value: string | number;
  label: string;
  icon: ResourceStr;
  iconColor: string;
}

@Component
export struct StatCardRow {
  @Prop items: StatRowItem[] = [];
  @Prop gap: number = 12;

  build() {
    Row() {
      ForEach(this.items, (item: StatRowItem, index: number) => {
        StatCard({
          value: item.value,
          label: item.label,
          icon: item.icon,
          iconColor: item.iconColor
        })
        .layoutWeight(1)

        if (index < this.items.length - 1) {
          Blank().width(this.gap)
        }
      })
    }
    .width('100%')
  }
}
