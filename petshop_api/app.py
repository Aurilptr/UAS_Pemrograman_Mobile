from flask import Flask, jsonify, request
import mysql.connector
from flask_cors import CORS
import random

app = Flask(__name__)
CORS(app) 

# Konfigurasi Database
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '', 
    'database': 'pawmate_db'
}

def get_db_connection():
    try:
        conn = mysql.connector.connect(**db_config)
        return conn
    except mysql.connector.Error as err:
        print(f"[SERVER ERROR] Database Connect: {err}") 
        return None

# ==========================================
# BAGIAN 1: UMUM & AUTH
# ==========================================

@app.route('/', methods=['GET'])
def index():
    print("[SERVER] CHECK: Health check requested")
    return jsonify({"message": "Pawmate API Ready (Client & Admin)!"}), 200

@app.route('/register', methods=['POST'])
def register():
    data = request.json
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    
    print(f"[SERVER] REGISTER REQUEST: {email}") 
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        if cursor.fetchone():
            print(f"[SERVER] REGISTER FAILED: Email {email} exists")
            return jsonify({"status": "error", "message": "Email sudah terdaftar!"}), 400
        
        cursor.execute("INSERT INTO users (name, email, password, role) VALUES (%s, %s, %s, 'client')", (name, email, password))
        conn.commit()
        print(f"[SERVER] REGISTER SUCCESS: New user {name} created")
        return jsonify({"status": "success", "message": "Registrasi berhasil!"}), 201
    except Exception as e:
        print(f"[SERVER] REGISTER ERROR: {str(e)}")
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')
    
    print(f"[SERVER] LOGIN ATTEMPT: {email}")
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM users WHERE email = %s AND password = %s", (email, password))
        user = cursor.fetchone()
        
        if user:
            print(f"[SERVER] LOGIN SUCCESS: {user['name']} ({user['role']})") 
            return jsonify({"status": "success", "data": user}), 200
        else:
            print(f"[SERVER] LOGIN FAILED: Invalid credentials for {email}")
            return jsonify({"status": "error", "message": "Email/Password salah"}), 401
    except Exception as e:
        print(f"[SERVER] LOGIN ERROR: {str(e)}")
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# ==========================================
# BAGIAN 2: FITUR CLIENT (BELANJA)
# ==========================================

@app.route('/products', methods=['GET'])
def get_products():
    print("[SERVER] FETCHING: All products list")
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM products ORDER BY id DESC")
        products = cursor.fetchall()
        print(f"[SERVER] FETCH SUCCESS: Found {len(products)} products")
        return jsonify({"status": "success", "data": products}), 200
    finally:
        cursor.close()
        conn.close()

@app.route('/my_orders/<int:user_id>', methods=['GET'])
def my_orders(user_id):
    print(f"[SERVER] FETCHING ORDERS: User ID {user_id}")
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True) 
    
    try:
        cursor.execute("SELECT * FROM orders WHERE user_id = %s ORDER BY created_at DESC", (user_id,))
        orders = cursor.fetchall()
        
        order_list = []
        for order in orders:
            order_data = order.copy()
            cursor.execute("""
                SELECT p.name, p.image_url AS image, od.quantity, od.price_per_unit AS price 
                FROM order_details od
                JOIN products p ON od.product_id = p.id
                WHERE od.order_id = %s
            """, (order['id'],))
            items = cursor.fetchall()
            order_data['items'] = items 
            order_data['total_item_count'] = sum(item['quantity'] for item in items)
            order_list.append(order_data)
            
        print(f"[SERVER] FETCH ORDERS SUCCESS: Found {len(order_list)} orders")
        return jsonify({'status': 'success', 'data': order_list})

    except Exception as e:
        print(f"[SERVER] FETCH ORDERS ERROR: {e}")
        return jsonify({'status': 'error', 'message': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/cart', methods=['POST'])
def add_to_cart():
    data = request.json
    u_id = data.get('user_id') 
    p_id = data.get('product_id')
    qty = data.get('quantity')

    print(f"[SERVER] CART: Adding product {p_id} for user {u_id} (Qty: {qty})")
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT quantity FROM carts WHERE user_id = %s AND product_id = %s", (u_id, p_id))
        existing_item = cursor.fetchone()

        if existing_item:
            new_qty = existing_item[0] + int(qty)
            cursor.execute("UPDATE carts SET quantity = %s WHERE user_id = %s AND product_id = %s", (new_qty, u_id, p_id))
            print("[SERVER] CART: Updated existing item quantity")
        else:
            cursor.execute("INSERT INTO carts (user_id, product_id, quantity) VALUES (%s, %s, %s)", (u_id, p_id, qty))
            print("[SERVER] CART: Inserted new item")
        
        conn.commit()
        return jsonify({"message": "Berhasil masuk keranjang", "status": "success"}), 200
    finally:
        cursor.close()
        conn.close()

@app.route('/cart/<int:user_id>', methods=['GET'])
def get_cart(user_id):
    print(f"[SERVER] CART: Fetching cart for user {user_id}")
    conn = get_db_connection()
    cursor = conn.cursor() 
    try:
        query = """
            SELECT c.id, c.quantity, p.name, p.price, p.image_url, p.stock, p.id 
            FROM carts c
            JOIN products p ON c.product_id = p.id
            WHERE c.user_id = %s
        """
        cursor.execute(query, (user_id,))
        data = cursor.fetchall()
        
        cart_items = []
        for row in data:
            cart_items.append({
                "id": row[0], "quantity": row[1], "name": row[2], "price": row[3],
                "image_url": row[4], "stock": row[5], "product_id": row[6]
            })
        print(f"[SERVER] CART: Found {len(cart_items)} items")
        return jsonify({"data": cart_items}), 200
    finally:
        cursor.close()
        conn.close()

@app.route('/cart/delete/<int:cart_id>', methods=['DELETE'])
def delete_cart_item(cart_id):
    print(f"[SERVER] CART: Deleting item ID {cart_id}")
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM carts WHERE id = %s", (cart_id,))
        conn.commit()
        return jsonify({"status": "success", "message": "Item berhasil dihapus"}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# ==========================================
# BAGIAN KHUSUS CHECKOUT
# ==========================================

@app.route('/checkout', methods=['POST'])
def checkout():
    print("[SERVER] CHECKOUT START")
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        data = request.json
        user_id = data.get('user_id')
        address = data.get('address')
        bank_name = data.get('bank_name')
        items = data.get('items') 

        if not user_id or not items:
            return jsonify({"message": "Data tidak lengkap"}), 400

        # 1. Hitung Total
        total_price = 0
        for item in items:
            total_price += (float(item['price']) * int(item['quantity']))

        # 2. Insert Orders
        query_order = "INSERT INTO orders (user_id, total_price, status, shipping_address, created_at) VALUES (%s, %s, 'pending_payment', %s, NOW())"
        cursor.execute(query_order, (user_id, total_price, address))
        order_id = cursor.lastrowid 

        # 3. Insert Payments
        va_number = f"{random.randint(1000,9999)}-{random.randint(100000,999999)}"
        query_payment = "INSERT INTO payments (order_id, bank_name, va_number, amount, payment_status) VALUES (%s, %s, %s, %s, 'pending')"
        cursor.execute(query_payment, (order_id, bank_name, va_number, total_price))

        # 4. Insert Details & Update Stock
        for item in items:
            qty = int(item['quantity'])
            prod_id = item['product_id']
            price = float(item['price'])

            cursor.execute("INSERT INTO order_details (order_id, product_id, quantity, price_per_unit) VALUES (%s, %s, %s, %s)", (order_id, prod_id, qty, price))
            cursor.execute("UPDATE products SET stock = stock - %s WHERE id = %s", (qty, prod_id))
            
        # 5. Clear Cart
        cursor.execute("DELETE FROM carts WHERE user_id = %s", (user_id,))

        conn.commit()
        print(f"[SERVER] CHECKOUT SUCCESS: Order ID {order_id} created, Stock updated.")
        return jsonify({"message": "Checkout berhasil", "order_id": order_id}), 201

    except Exception as e:
        conn.rollback()
        print(f"[SERVER] CHECKOUT FAILED: {str(e)}")
        return jsonify({"message": "Checkout gagal", "error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()


@app.route('/pay_confirm', methods=['POST'])
def pay_confirm():
    data = request.json
    order_id = data.get('order_id')
    print(f"[SERVER] PAYMENT CONFIRM: Client confirmed transfer for Order {order_id}")
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("UPDATE orders SET status = 'waiting_confirmation' WHERE id = %s", (order_id,))
        conn.commit()
        return jsonify({"status": "success", "message": "Menunggu konfirmasi admin"}), 200
    finally:
        cursor.close()
        conn.close()

# ==========================================
# BAGIAN 3: FITUR ADMIN
# ==========================================

@app.route('/admin/products', methods=['POST'])
def add_product():
    data = request.json
    print(f"[SERVER] ADMIN: Adding product {data['name']}")
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        query = "INSERT INTO products (name, description, price, stock, category, image_url) VALUES (%s, %s, %s, %s, %s, %s)"
        cursor.execute(query, (data['name'], data['description'], data['price'], data['stock'], data['category'], data['image_url']))
        conn.commit()
        return jsonify({"status": "success", "message": "Produk ditambahkan"}), 201
    except Exception as e:
        print(f"[SERVER] ADMIN ADD PRODUCT ERROR: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/admin/products/<int:id>', methods=['DELETE'])
def delete_product(id):
    print(f"[SERVER] ADMIN: Deleting product ID {id}")
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM products WHERE id = %s", (id,))
        conn.commit()
        return jsonify({"status": "success", "message": "Produk dihapus"}), 200
    finally:
        cursor.close()
        conn.close()

# --- REVISI: MENAMBAHKAN ENDPOINT UPDATE PRODUK (PUT) ---
@app.route('/admin/products/<int:id>', methods=['PUT'])
def update_product(id):
    data = request.json
    print(f"[SERVER] ADMIN: Updating product ID {id}")
    
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        query = """
            UPDATE products 
            SET name = %s, description = %s, price = %s, stock = %s, category = %s, image_url = %s
            WHERE id = %s
        """
        cursor.execute(query, (
            data['name'], 
            data['description'], 
            data['price'], 
            data['stock'], 
            data['category'], 
            data['image_url'], 
            id
        ))
        conn.commit()
        return jsonify({"status": "success", "message": "Produk berhasil diperbarui"}), 200
    except Exception as e:
        print(f"[SERVER] ADMIN UPDATE PRODUCT ERROR: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        cursor.close()
        conn.close()
# --------------------------------------------------------

@app.route('/admin/orders', methods=['GET'])
def get_all_orders():
    print("[SERVER] ADMIN: Fetching all orders")
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        # REVISI: Pastikan cancel_reason terambil
        query = """
            SELECT 
                o.id, 
                o.total_price, 
                o.status, 
                o.cancel_reason, 
                o.created_at, 
                u.name as buyer_name,
                (SELECT p.image_url 
                 FROM order_details od 
                 JOIN products p ON od.product_id = p.id 
                 WHERE od.order_id = o.id 
                 LIMIT 1) as product_image
            FROM orders o 
            JOIN users u ON o.user_id = u.id 
            ORDER BY o.id DESC
        """
        cursor.execute(query)
        orders = cursor.fetchall()
        print(f"[SERVER] ADMIN: Found {len(orders)} total orders")
        return jsonify({"status": "success", "data": orders}), 200
    finally:
        cursor.close()
        conn.close()

@app.route('/admin/order_status', methods=['POST'])
def update_order_status():
    data = request.json
    order_id = data.get('order_id')
    new_status = data.get('status')
    cancel_reason = data.get('cancel_reason') 
    
    print(f"[SERVER] ADMIN UPDATE STATUS: Order {order_id} -> {new_status}. Reason: {cancel_reason}")
    
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        if cancel_reason:
            cursor.execute("UPDATE orders SET status = %s, cancel_reason = %s WHERE id = %s", (new_status, cancel_reason, order_id))
            
            if new_status == 'cancelled':
                 cursor.execute("UPDATE payments SET payment_status = 'cancelled' WHERE order_id = %s", (order_id,))
                 
                 cursor.execute("SELECT product_id, quantity FROM order_details WHERE order_id = %s", (order_id,))
                 items = cursor.fetchall()
                 for item in items:
                    cursor.execute("UPDATE products SET stock = stock + %s WHERE id = %s", (item[1], item[0]))
                 print(f"[SERVER] SYSTEM: Order {order_id} CANCELLED BY ADMIN. Stock restored.")

        else:
            cursor.execute("UPDATE orders SET status = %s WHERE id = %s", (new_status, order_id))
        
        if new_status == 'paid':
             cursor.execute("UPDATE payments SET payment_status = 'confirmed' WHERE order_id = %s", (order_id,))
             print(f"[SERVER] SYSTEM: Payment automatically confirmed for Order {order_id}")
        
        elif new_status == 'shipped':
             print(f"[SERVER] SYSTEM: Order {order_id} marked as SHIPPED")

        conn.commit()
        return jsonify({"status": "success", "message": "Status diperbarui"}), 200
    except Exception as e:
        print(f"[SERVER] UPDATE STATUS ERROR: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/admin/users', methods=['GET'])
def get_all_users():
    print("[SERVER] ADMIN: Fetching all registered users")
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        # Mengambil semua user kecuali password (demi keamanan)
        cursor.execute("SELECT id, name, email, role FROM users ORDER BY id DESC")
        users = cursor.fetchall()
        print(f"[SERVER] ADMIN: Found {len(users)} users")
        return jsonify({"status": "success", "data": users}), 200
    except Exception as e:
        print(f"[SERVER] ADMIN FETCH USERS ERROR: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/admin/stats', methods=['GET'])
def get_admin_stats():
    print("[SERVER] ADMIN: Fetching Business Statistics")
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        # 1. Hitung Total Pendapatan (Hanya dari pesanan yang valid/dibayar)
        cursor.execute("SELECT SUM(total_price) as income FROM orders WHERE status IN ('paid', 'shipped', 'completed')")
        income_res = cursor.fetchone()
        total_income = float(income_res['income']) if income_res['income'] else 0.0

        # 2. Hitung Total Pesanan
        cursor.execute("SELECT COUNT(id) as total_orders FROM orders")
        orders_res = cursor.fetchone()

        # 3. Hitung Total Produk
        cursor.execute("SELECT COUNT(id) as total_products FROM products")
        products_res = cursor.fetchone()

        # 4. Hitung Total User
        cursor.execute("SELECT COUNT(id) as total_users FROM users WHERE role = 'client'")
        users_res = cursor.fetchone()

        stats = {
            "total_income": total_income,
            "total_orders": orders_res['total_orders'],
            "total_products": products_res['total_products'],
            "total_users": users_res['total_users']
        }

        return jsonify({"status": "success", "data": stats}), 200
    except Exception as e:
        print(f"[SERVER] STATS ERROR: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# ==========================================
# BAGIAN 4: FITUR CANCEL (CLIENT SIDE)
# ==========================================

@app.route('/orders/cancel', methods=['POST'])
def cancel_order():
    data = request.json
    order_id = data.get('order_id')
    reason = data.get('reason')

    print(f"[SERVER] CANCEL REQUEST (CLIENT): Order {order_id}, Reason: {reason}")
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT status FROM orders WHERE id = %s", (order_id,))
        result = cursor.fetchone()
        
        if not result:
             return jsonify({"status": "error", "message": "Order tidak ditemukan"}), 404
             
        current_status = result[0]
        if current_status in ['shipped', 'completed', 'cancelled']:
             print(f"[SERVER] CANCEL REJECTED: Status is {current_status}")
             return jsonify({"status": "error", "message": f"Tidak bisa batal, status pesanan: {current_status}"}), 400

        cursor.execute("UPDATE orders SET status = 'cancelled', cancel_reason = %s WHERE id = %s", (reason, order_id))
        cursor.execute("UPDATE payments SET payment_status = 'cancelled' WHERE order_id = %s", (order_id,))

        # RESTOCK
        cursor.execute("SELECT product_id, quantity FROM order_details WHERE order_id = %s", (order_id,))
        items = cursor.fetchall()
        for item in items:
            cursor.execute("UPDATE products SET stock = stock + %s WHERE id = %s", (item[1], item[0]))

        conn.commit()
        print(f"[SERVER] CANCEL SUCCESS: Order {order_id} cancelled & Restocked.")
        return jsonify({"status": "success", "message": "Pesanan dibatalkan & stok dikembalikan"}), 200
    except Exception as e:
        conn.rollback()
        print(f"[SERVER] CANCEL ERROR: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# ==========================================
# BAGIAN 5: FITUR UPDATE PROFILE
# ==========================================

@app.route('/update_profile/<int:user_id>', methods=['PUT'])
def update_profile(user_id):
    data = request.json
    new_name = data.get('name')
    new_password = data.get('password')
    
    print(f"[SERVER] PROFILE UPDATE: User {user_id}")
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        if new_password and new_password.strip() != "":
            cursor.execute("UPDATE users SET name = %s, password = %s WHERE id = %s", (new_name, new_password, user_id))
        else:
            cursor.execute("UPDATE users SET name = %s WHERE id = %s", (new_name, user_id))
            
        conn.commit()
        return jsonify({'status': 'success', 'message': 'Profil berhasil diperbarui'})
    except Exception as e:
        print(f"[SERVER] PROFILE UPDATE ERROR: {e}")
        return jsonify({'status': 'error', 'message': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    print("[SERVER] Pawmate Full Server Started... (Logging Enabled)")
    app.run(debug=True, host='0.0.0.0', port=5000)