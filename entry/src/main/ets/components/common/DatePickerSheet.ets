import { HarmonyColor } from '../../common/HarmonyDesign';

@Component
export struct DatePickerSheet {
  @Prop title: string = '';
  @Prop selectedDate: Date = new Date();
  onDateChange?: (date: Date) => void;
  onConfirm?: () => void;

  build() {
    Column() {
      Text(this.title)
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 8, bottom: 16 })

      DatePicker({
        start: new Date(2020, 0, 1),
        end: new Date(2035, 11, 31),
        selected: this.selectedDate
      })
        .width('100%')
        .onDateChange((value: Date) => {
          if (this.onDateChange) {
            this.onDateChange(value);
          }
        })

      Button('确定')
        .width('100%')
        .height(44)
        .margin({ top: 20 })
        .fontSize($r('app.float.text_primary_size'))
        .fontColor(HarmonyColor.textInverse)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(18)
        .onClick(() => {
          if (this.onConfirm) {
            this.onConfirm();
          }
        })
    }
    .width('100%')
    .padding(20)
  }
}
