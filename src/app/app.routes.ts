import { Routes } from '@angular/router';
import { HomeComponent } from './pages/home/home.component';
import { AboutComponent } from './pages/about/about.component';
import { ProductsComponent } from './pages/products/products.component';
import { IndustriesComponent } from './pages/industries/industries.component';
import { CapabilitiesComponent } from './pages/capabilities/capabilities.component';
import { SustainabilityComponent } from './pages/sustainability/sustainability.component';
import { CareersComponent } from './pages/careers/careers.component';
import { BlogComponent } from './pages/blog/blog.component';
import { ContactComponent } from './pages/contact/contact.component';
import { PortalComponent } from './pages/portal/portal.component';

export const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'about', component: AboutComponent },
  { path: 'products', component: ProductsComponent },
  { path: 'industries', component: IndustriesComponent },
  { path: 'capabilities', component: CapabilitiesComponent },
  { path: 'sustainability', component: SustainabilityComponent },
  { path: 'careers', component: CareersComponent },
  { path: 'blog', component: BlogComponent },
  { path: 'contact', component: ContactComponent },
  { path: 'portal', component: PortalComponent },
  { path: '**', redirectTo: '' }
];
