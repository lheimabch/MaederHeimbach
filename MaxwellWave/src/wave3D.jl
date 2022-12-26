@doc raw"""
    @parallel_indices (ix, iy, iz) function update_vecu!(ux, uy, uz, vx, vy, vz, dt)

Computes the update rule for the vector field through the equation:
```math
\vec{u}^{j+1} = \vec{u}^{j} + dt*\vec{v}^{j+\frac{1}{2}}
```
Important to call the kernel with size(u)-2
"""
@parallel_indices (ix, iy, iz) function update_vecu!(ux, uy, uz, vx, vy, vz, dt)
    ux[ix+1, iy+1, iz+1] = ux[ix+1, iy+1, iz+1] + dt * vx[ix+1, iy+1, iz+1]
    uy[ix+1, iy+1, iz+1] = uy[ix+1, iy+1, iz+1] + dt * vy[ix+1, iy+1, iz+1]
    uz[ix+1, iy+1, iz+1] = uz[ix+1, iy+1, iz+1] + dt * vz[ix+1, iy+1, iz+1]
    return nothing
end

@doc raw"""
    @parallel_indices (ix, iy, iz) function update_vecv_nabla2!(ux, uy, uz, vx, vy, vz, dt, _dx2, _dy2, _dz2, alpha)

Computes the update rule for the velocity of the vector field through the equation:
```math
\vec{v}^{j+\frac{1}{2}} = \vec{v}^{j-\frac{1}{2}} + dt*\alpha\left(\vec{r}\right) \nabla^2 \vec{u}^{j}
```
"""
@parallel_indices (ix, iy, iz) function update_vecv_nabla2!(ux, uy, uz, vx, vy, vz, dt, _dx2, _dy2, _dz2, alpha)
    nx, ny, nz = size(ux)
    if (ix >= 2 && iy >= 2 && iz >= 2 && ix <= nx - 1 && iy <= ny - 1 && iz <= nz - 1)
        vx[ix, iy, iz] = vx[ix, iy, iz] + dt * alpha[ix, iy, iz] * ((ux[ix+1, iy, iz] - 2 * ux[ix, iy, iz] + ux[ix-1, iy, iz]) * _dx2 + (ux[ix, iy+1, iz] - 2 * ux[ix, iy, iz] + ux[ix, iy-1, iz]) * _dy2 + (ux[ix, iy, iz+1] - 2 * ux[ix, iy, iz] + ux[ix, iy, iz-1]) * _dz2)
        vy[ix, iy, iz] = vy[ix, iy, iz] + dt * alpha[ix, iy, iz] * ((uy[ix+1, iy, iz] - 2 * uy[ix, iy, iz] + uy[ix-1, iy, iz]) * _dx2 + (uy[ix, iy+1, iz] - 2 * uy[ix, iy, iz] + uy[ix, iy-1, iz]) * _dy2 + (uy[ix, iy, iz+1] - 2 * uy[ix, iy, iz] + uy[ix, iy, iz-1]) * _dz2)
        vz[ix, iy, iz] = vz[ix, iy, iz] + dt * alpha[ix, iy, iz] * ((uz[ix+1, iy, iz] - 2 * uz[ix, iy, iz] + uz[ix-1, iy, iz]) * _dx2 + (uz[ix, iy+1, iz] - 2 * uz[ix, iy, iz] + uz[ix, iy-1, iz]) * _dy2 + (uz[ix, iy, iz+1] - 2 * uz[ix, iy, iz] + uz[ix, iy, iz-1]) * _dz2)
    end
    return nothing
end

@doc raw"""
    @parallel_indices (ix, iy, iz) function update_vecv_sigma!(ux, uy, uz, vx, vy, vz, dt, beta, gamma)

Computes the update rule for the velocity of the vector field through the equation:
```math
\vec{v}^{j+\frac{1}{2}} = \vec{v}^{j-\frac{1}{2}} + dt*\beta\left(\vec{r}\right) \vec{u}^{j} + dt*\gamma\left(\vec{r}\right) \vec{v}^{j-\frac{1}{2}}
```
Important to call the kernel with size(u)-2
"""
@parallel_indices (ix, iy, iz) function update_vecv_sigma!(ux, uy, uz, vx, vy, vz, dt, beta, gamma)
    vx[ix+1, iy+1, iz+1] = (1 + dt * gamma[ix+1, iy+1, iz+1]) * vx[ix+1, iy+1, iz+1] + dt * beta[ix+1, iy+1, iz+1] * ux[ix+1, iy+1, iz+1]
    vy[ix+1, iy+1, iz+1] = (1 + dt * gamma[ix+1, iy+1, iz+1]) * vy[ix+1, iy+1, iz+1] + dt * beta[ix+1, iy+1, iz+1] * uy[ix+1, iy+1, iz+1]
    vz[ix+1, iy+1, iz+1] = (1 + dt * gamma[ix+1, iy+1, iz+1]) * vz[ix+1, iy+1, iz+1] + dt * beta[ix+1, iy+1, iz+1] * uz[ix+1, iy+1, iz+1]
    return nothing
end

@doc raw"""
    @parallel_indices (ix, iy, iz) function update_vecv_varepsilon!(ux, uy, uz, vx, vy, vz, dt, _dx_2, _dy_2, _dz_2, alpha, etax, etay, etaz)

Computes the update rule for the velocity of the vector field through the equation:
```math
\vec{v}^{j+\frac{1}{2}} = \vec{v}^{j-\frac{1}{2}} + dt*\alpha\left(\vec{r}\right) \nabla \left(\vec{\eta}\left(\vec{r}\right) \cdot \vec{u}^{j} \right)
```
"""
@parallel_indices (ix, iy, iz) function update_vecv_varepsilon!(ux, uy, uz, vx, vy, vz, dt, _dx_2, _dy_2, _dz_2, alpha, etax, etay, etaz)
    nx, ny, nz = size(ux)
    if (ix >= 2 && iy >= 2 && iz >= 2 && ix <= nx - 1 && iy <= ny - 1 && iz <= nz - 1)
        vx[ix, iy, iz] = vx[ix, iy, iz] + dt * alpha[ix, iy, iz] * (etax[ix+1, iy, iz] * ux[ix+1, iy, iz] - etax[ix-1, iy, iz] * ux[ix-1, iy, iz] +
                                                                        etay[ix+1, iy, iz] * uy[ix+1, iy, iz] - etay[ix-1, iy, iz] * uy[ix-1, iy, iz] +
                                                                        etaz[ix+1, iy, iz] * uz[ix+1, iy, iz] - etaz[ix-1, iy, iz] * uz[ix-1, iy, iz]) * _dx_2

        vy[ix, iy, iz] = vy[ix, iy, iz] + dt * alpha[ix, iy, iz] * (etax[ix, iy+1, iz] * ux[ix, iy+1, iz] - etax[ix, iy-1, iz] * ux[ix, iy-1, iz] +
                                                                        etay[ix, iy+1, iz] * uy[ix, iy+1, iz] - etay[ix, iy-1, iz] * uy[ix, iy-1, iz] +
                                                                        etaz[ix, iy+1, iz] * uz[ix, iy+1, iz] - etaz[ix, iy-1, iz] * uz[ix, iy-1, iz]) * _dy_2

        vz[ix, iy, iz] = vz[ix, iy, iz] + dt * alpha[ix, iy, iz] * (etax[ix, iy, iz+1] * ux[ix, iy, iz+1] - etax[ix, iy, iz-1] * ux[ix, iy, iz-1] +
                                                                        etay[ix, iy, iz+1] * uy[ix, iy, iz+1] - etay[ix, iy, iz-1] * uy[ix, iy, iz-1] +
                                                                        etaz[ix, iy, iz+1] * uz[ix, iy, iz+1] - etaz[ix, iy, iz-1] * uz[ix, iy, iz-1]) * _dz_2

    end
    return nothing
end