import { Component } from '@angular/core';
import { TranslatePipe } from '../../pipes/translate.pipe';

@Component({
  selector: 'app-sustainability',
  standalone: true,
  imports: [TranslatePipe],
  templateUrl: './sustainability.component.html',
  styleUrl: './sustainability.component.scss'
})
export class SustainabilityComponent {

}
