import { HarmonyColor } from '../../common/HarmonyDesign';

@Component
export struct SelectionSheet {
  @Prop title: string = '';
  @Prop selectedValue: string = '';
  @Prop options: string[] = [];
  onSelect?: (value: string) => void;

  build() {
    Column() {
      Text(this.title)
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 8, bottom: 16 })

      List({ space: 0 }) {
        ForEach(this.options, (option: string) => {
          ListItem() {
            Row() {
              Text(option)
                .fontSize($r('app.float.text_primary_size'))
                .fontWeight(this.selectedValue === option ? FontWeight.Medium : FontWeight.Normal)
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)

              if (this.selectedValue === option) {
                Image($r('app.media.ic_success'))
                  .width(18)
                  .height(18)
              }
            }
            .width('100%')
            .padding({ top: 14, bottom: 14 })
            .onClick(() => {
              if (this.onSelect) {
                this.onSelect(option);
              }
            })
          }
        })
      }
      .width('100%')
      .divider({ strokeWidth: 1, color: HarmonyColor.line })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .padding(20)
  }
}
