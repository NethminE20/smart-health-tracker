# app/routes/users.py
from fastapi import APIRouter, HTTPException, Depends
from app.models.user import User, UserLogin
from app.services.user_service import (
    add_user_to_db,
    authenticate_user,
    create_access_token,
    get_all_users,
    delete_user,
    update_profile,
    get_profile,
    delete_profile
)
from app.routes.auth import get_current_user
from fastapi import File, Form, UploadFile
from app.models.user import UserProfile

router = APIRouter()

# =====================
# Get Profile (protected)
# =====================
@router.get("/users/profile/get")
async def get_user_profile(current_user: str = Depends(get_current_user)):
    user = await get_profile(current_user)
    if not user:
        raise HTTPException(status_code=404, detail="Profile not found")
    return user

# =====================
# Update Profile (protected)
# =====================
@router.put("/users/profile")
async def update_user_profile(
    name: str = Form(None),
    age: int = Form(None),
    bio: str = Form(None),
    file: UploadFile = File(None),
    current_user: str = Depends(get_current_user)
):
    profile_data = {"name": name, "age": age, "bio": bio}
    updated = await update_profile(current_user, profile_data, file)
    if not updated:
        raise HTTPException(status_code=400, detail="No data provided")
    return {"message": "Profile updated successfully"}

# =====================
# Delete Profile (protected)
# =====================
@router.delete("/users/profile/delete")
async def remove_user_profile(current_user: str = Depends(get_current_user)):
    deleted = await delete_profile(current_user)
    if not deleted:
        raise HTTPException(status_code=404, detail="Profile not found")
    return {"message": f"Profile for {current_user} deleted successfully"}

# =====================
# Signup (register new user)
# =====================
@router.post("/signup/")
async def signup(user: User):
    user_id = await add_user_to_db(user)
    return {"inserted_id": user_id}

# =====================
# Login
# =====================
@router.post("/login/")
async def login(user: UserLogin):
    db_user = await authenticate_user(user.email, user.password)
    if not db_user:
        raise HTTPException(status_code=401, detail="Invalid email or password")
    token = create_access_token({"sub": db_user["email"]})
    return {"access_token": token, "token_type": "bearer"}

# =====================
# Get all users (public - not recommended)
# =====================
@router.get("/users/public")
async def list_users_public():
    users = await get_all_users()
    return users

# =====================
# Get all users (protected - requires login)
# =====================
@router.get("/users/")
async def list_users_protected(current_user: str = Depends(get_current_user)):
    users = await get_all_users()
    return users

# =====================
# Delete user by sequential user_id (protected)
# =====================
@router.delete("/users/{user_id}")
async def remove_user(user_id: int, current_user: str = Depends(get_current_user)):
    deleted = await delete_user(user_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="User not found")
    return {"message": f"User {user_id} deleted successfully"}


